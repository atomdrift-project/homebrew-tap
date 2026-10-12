"""Regression tests for incomplete releases, pagination, and safe upgrades."""

import importlib.util
import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

TOOLS = Path(__file__).resolve().parents[1]
ROOT = TOOLS.parent
sys.path.insert(0, str(TOOLS))
from releases import URL_RE, asset_names, current_tag, version_key


def load(name):
    spec = importlib.util.spec_from_file_location(name, TOOLS / f"{name}.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


latest = load("latest-release")
upgrade = load("upgrade-binary")


def release(tag, path=Path("scan.rb"), missing=(), draft=False):
    names = asset_names(path, tag) + ["SHA256SUMS", "SHA256SUMS.sigstore.json"]
    return {"tag_name": tag, "draft": draft, "prerelease": "-" in tag,
            "published_at": "2026-08-01T12:00:00Z",
            "assets": [{"name": name, "state": "uploaded", "size": 100}
                       for name in names if name not in missing]}


class DiscoveryTests(unittest.TestCase):
    def setUp(self):
        self.path = Path("scan.rb")
        self.text = (ROOT / "Formula/scan.rb").read_text()
        self.current = current_tag(self.text)

    def select(self, releases):
        return latest.select_release(self.path, self.text, releases)

    def test_numeric_order_ignores_api_order_and_release_backfills(self):
        result = self.select([release("v2.9.0"), release("v2.20.0"), release("v2.19.0")])
        self.assertEqual(result["tag"], "v2.20.0")

    def test_incomplete_newer_release_uses_complete_predecessor(self):
        for missing in ["SHA256SUMS", "SHA256SUMS.sigstore.json", *asset_names(self.path, "v3.0.0")]:
            with self.subTest(missing=missing):
                result = self.select([release("v3.0.0", missing=[missing]), release("v2.20.0")])
                self.assertEqual(result["tag"], "v2.20.0")
                self.assertEqual(result["latest"], "v3.0.0")

    def test_upload_in_progress_or_empty_asset_is_incomplete(self):
        for field, value in [("state", "new"), ("size", 0)]:
            newest = release("v3.0.0")
            newest["assets"][0][field] = value
            self.assertEqual(self.select([newest])["status"], "wait")

    def test_never_downgrades_or_falls_back_to_source(self):
        result = self.select([release("v3.0.0", missing=["SHA256SUMS"]), release("v1.0.0")])
        self.assertEqual(result["status"], "wait")
        self.assertEqual(result["mode"], "binary")
        self.assertEqual(result["tag"], "")

    def test_already_current_needs_no_download(self):
        result = self.select([release(self.current)])
        self.assertEqual(result["status"], "ok")

    def test_drafts_are_excluded_and_prereleases_order_numerically(self):
        result = self.select([release("v9.0.0", draft=True), release("v3.0.0-rc.9"), release("v3.0.0-rc.10")])
        self.assertEqual(result["tag"], "v3.0.0-rc.10")
        self.assertGreater(version_key("v3.0.0"), version_key("v3.0.0-rc.10"))

    def test_no_releases_and_unrecognized_historical_tags(self):
        self.assertEqual(self.select([])["status"], "none")
        self.assertEqual(self.select([{"tag_name": "nightly", "draft": False}])["status"], "none")

    def test_inconsistent_binary_tags_fail(self):
        text = self.text.replace(f"/download/{self.current}/", "/download/v1.0.0/", 1)
        with self.assertRaises(ValueError):
            latest.select_release(self.path, text, [])

    def test_source_conversion_even_when_version_is_already_current(self):
        path = Path("filefacts.rb")
        text = (ROOT / "Formula/filefacts.rb").read_text()
        tag = current_tag(text)
        result = latest.select_release(path, text, [release(tag, path)])
        self.assertEqual((result["status"], result["mode"]), ("bump", "binary"))

    def test_source_only_repository_and_incomplete_binary_pipeline(self):
        path = Path("filefacts.rb")
        text = (ROOT / "Formula/filefacts.rb").read_text()
        newest = release("v3.0.0", path)
        newest["assets"] = []
        result = latest.select_release(path, text, [newest])
        self.assertEqual((result["status"], result["mode"]), ("bump", "source"))
        newest = release("v3.0.0", path, missing=["SHA256SUMS.sigstore.json"])
        self.assertEqual(latest.select_release(path, text, [newest])["status"], "wait")

    def test_cli_reads_every_page_in_one_gh_invocation(self):
        pages = [[release(f"v3.0.{i}", missing=["SHA256SUMS"]) for i in range(100)],
                 [release("v2.20.0")]]
        with patch.object(sys, "argv", ["latest-release.py", str(ROOT / "Formula/scan.rb"), "atomdrift-project/scan"]), \
                patch.object(latest.subprocess, "run", return_value=subprocess.CompletedProcess([], 0, json.dumps(pages))) as run, \
                patch("builtins.print") as output:
            latest.main()
        self.assertEqual(json.loads(output.call_args.args[0])["tag"], "v2.20.0")
        self.assertEqual(run.call_count, 1)
        self.assertIn("--paginate", run.call_args.args[0])
        self.assertIn("per_page=100", run.call_args.args[0][2])

    def test_api_error_is_not_hidden_as_no_releases(self):
        with patch.object(sys, "argv", ["latest-release.py", "scan.rb", "atomdrift-project/scan"]), \
                patch.object(latest.subprocess, "run", side_effect=subprocess.CalledProcessError(1, "gh")):
            with self.assertRaises(subprocess.CalledProcessError):
                latest.main()


class UpgradeTests(unittest.TestCase):
    def setUp(self):
        self.path = Path("scan.rb")
        self.text = (ROOT / "Formula/scan.rb").read_text()
        self.tag = "v3.0.0-rc.10"
        self.sums = {asset: str(i) * 64 for i, asset in enumerate(asset_names(self.path, self.tag), 1)}

    def test_updates_all_urls_and_checksums_preserving_head_and_dependencies(self):
        updated = upgrade.upgrade(self.text, self.path, "atomdrift-project/scan", self.tag, self.sums)
        self.assertEqual(current_tag(updated), self.tag)
        self.assertIn('url "https://github.com/atomdrift-project/scan.git", branch: "main"', updated)
        self.assertIn('depends_on "sevenzip" => :recommended', updated)
        for digest in self.sums.values():
            self.assertIn(f'sha256 "{digest}"', updated)

    def test_conversion_moves_rust_to_head_and_preserves_runtime_dependencies(self):
        path = Path("filefacts.rb")
        source = (ROOT / "Formula/filefacts.rb").read_text()
        sums = {asset: "a" * 64 for asset in asset_names(path, self.tag)}
        updated = upgrade.upgrade(source, path, "atomdrift-project/filefacts", self.tag, sums)
        self.assertEqual(len(list(URL_RE.finditer(updated))), 4)
        self.assertNotIn("revision:", updated)
        self.assertIn('head do\n    url "https://github.com/atomdrift-project/filefacts.git", branch: "main"\n\n    depends_on "rust" => :build\n  end', updated)
        self.assertIn('bin.install "filefacts"', updated)
        self.assertIn('depends_on "rizin" => :recommended', updated)

    def test_same_version_conversion_bumps_revision_and_next_version_resets_it(self):
        path = Path("filefacts.rb")
        source = (ROOT / "Formula/filefacts.rb").read_text()
        tag = current_tag(source)
        sums = {asset: "a" * 64 for asset in asset_names(path, tag)}
        converted = upgrade.upgrade(source, path, "atomdrift-project/filefacts", tag, sums)
        self.assertIn("  revision 1\n", converted)
        sums = {asset: "b" * 64 for asset in asset_names(path, self.tag)}
        bumped = upgrade.upgrade(converted, path, "atomdrift-project/filefacts", self.tag, sums)
        self.assertNotIn("  revision ", bumped)

    def test_missing_adjacent_checksum_does_not_use_another_platform(self):
        text = self.text.replace('      sha256 "', '      # sha256 "', 1)
        with self.assertRaises(ValueError):
            upgrade.upgrade(text, self.path, "atomdrift-project/scan", self.tag, self.sums)

    def test_missing_checksum_leaves_formula_unchanged(self):
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "scan.rb"
            path.write_text(self.text)
            sums = Path(directory) / "SHA256SUMS"
            sums.write_text(f"{'a' * 64}  {asset_names(self.path, self.tag)[0]}\n")
            with patch.object(sys, "argv", ["upgrade-binary.py", str(path), "atomdrift-project/scan", self.tag, str(sums)]):
                with self.assertRaises(SystemExit):
                    upgrade.main()
            self.assertEqual(path.read_text(), self.text)

    def test_checksum_formats_and_validation(self):
        self.assertEqual(upgrade.parse_sums(f"{'A' * 64}  ./one.tar.gz\n{'b' * 64} *two.tar.gz\n", "test"),
                         {"one.tar.gz": "a" * 64, "two.tar.gz": "b" * 64})
        for text in ["", "not-a-checksum  one.tar.gz", f"{'a' * 64}  one\n{'b' * 64}  one\n"]:
            with self.subTest(text=text), self.assertRaises(ValueError):
                upgrade.parse_sums(text, "test")


if __name__ == "__main__":
    unittest.main()
