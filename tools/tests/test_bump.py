"""Exercise the CI shell entry point with local release and signing fixtures."""

import json
import os
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

from test_releases import ROOT, asset_names, current_tag, release


class BumpTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.work = Path(self.directory.name)
        shutil.copytree(ROOT / "tools", self.work / "tools")
        shutil.copytree(ROOT / "Formula", self.work / "Formula")
        shutil.copy(ROOT / "Makefile", self.work)
        self.bin = self.work / "bin"
        self.bin.mkdir()
        self.log = self.work / "commands"
        self.env = os.environ | {
            "PATH": f"{self.bin}{os.pathsep}{os.environ['PATH']}",
            "FIXTURE_DIR": str(self.work), "COMMAND_LOG": str(self.log),
            "ONLY": "scan", "SOURCE_GATE_MINUTES": "360", "STUCK_WARN_MINUTES": "360",
            "GITHUB_STEP_SUMMARY": str(self.work / "summary"),
            "PYTHONDONTWRITEBYTECODE": "1", "SIGNATURE_STATUS": "0", "API_STATUS": "0",
        }
        self.write_tool("gh", '''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
with open(os.environ["COMMAND_LOG"], "a") as log:
    log.write("gh " + " ".join(args) + "\\n")
fixture = Path(os.environ["FIXTURE_DIR"])
if args[0] == "api":
    if os.environ["API_STATUS"] != "0":
        sys.exit(int(os.environ["API_STATUS"]))
    print((fixture / "releases.json").read_text())
else:
    out = Path(args[args.index("--dir") + 1])
    (out / "SHA256SUMS").write_text((fixture / "SHA256SUMS").read_text())
    (out / "SHA256SUMS.sigstore.json").write_text("fixture bundle")
''')
        self.write_tool("cosign", '''#!/bin/sh
echo "cosign $*" >> "$COMMAND_LOG"
exit "$SIGNATURE_STATUS"
''')
        for command in ("git", "brew"):
            self.write_tool(command, f'''#!/bin/sh
echo "{command} $*" >> "$COMMAND_LOG"
if [ "{command}" = git ] && [ "$1" = ls-remote ]; then
  printf '%s\\t%s\\n' aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa refs/tags/v3.0.0
fi
''')

    def write_tool(self, name, source):
        path = self.bin / name
        path.write_text(source)
        path.chmod(0o755)

    def run_bump(self, releases):
        (self.work / "releases.json").write_text(json.dumps([releases]))
        (self.work / "SHA256SUMS").write_text("".join(
            f"{'a' * 64}  {asset}\n" for asset in asset_names(Path(self.env["ONLY"] + ".rb"), "v3.0.0")
        ))
        return subprocess.run(["bash", "tools/bump.sh"], cwd=self.work,
                              env=self.env, text=True, capture_output=True)

    def test_signed_release_is_updated_then_staged_and_pushed(self):
        result = self.run_bump([release("v3.0.0")])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(current_tag((self.work / "Formula/scan.rb").read_text()), "v3.0.0")
        log = self.log.read_text()
        self.assertLess(log.index("cosign verify-blob"), log.index("git add Formula/scan.rb"))
        self.assertIn("git push", log)
        self.assertIn("scan@v3.0.0(binary)", (self.work / "summary").read_text())

    def test_invalid_signature_blocks_changes_and_push(self):
        original = (self.work / "Formula/scan.rb").read_text()
        self.env["SIGNATURE_STATUS"] = "1"
        result = self.run_bump([release("v3.0.0")])
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual((self.work / "Formula/scan.rb").read_text(), original)
        self.assertNotIn("git add", self.log.read_text())
        self.assertNotIn("git push", self.log.read_text())

    def test_current_release_does_not_download_or_verify_again(self):
        tag = current_tag((self.work / "Formula/scan.rb").read_text())
        result = self.run_bump([release(tag)])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        log = self.log.read_text()
        self.assertNotIn("gh release download", log)
        self.assertNotIn("cosign", log)
        self.assertNotIn("git push", log)

    def test_api_error_fails_run_without_modifications(self):
        self.env["API_STATUS"] = "1"
        result = self.run_bump([release("v3.0.0")])
        self.assertNotEqual(result.returncode, 0)
        self.assertNotIn("git add", self.log.read_text())
        self.assertNotIn("git push", self.log.read_text())

    def test_unknown_formula_is_rejected(self):
        self.env["ONLY"] = "unknown"
        result = self.run_bump([])
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("unknown formula", result.stdout)

    def test_source_only_tool_is_tracked_and_keeps_build_dependencies(self):
        self.env["ONLY"] = "hood"
        candidate = release("v3.0.0", Path("hood.rb"))
        candidate["assets"] = []
        result = self.run_bump([candidate])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        updated = (self.work / "Formula/hood.rb").read_text()
        self.assertEqual(current_tag(updated), "v3.0.0")
        self.assertIn('depends_on "rust" => :build', updated)
        self.assertNotIn("cosign", self.log.read_text())

    def test_source_gate_waits_for_potential_binary_uploads(self):
        self.env["ONLY"] = "hood"
        self.env["SOURCE_GATE_MINUTES"] = "999999999"
        candidate = release("v3.0.0", Path("hood.rb"))
        candidate["assets"] = []
        result = self.run_bump([candidate])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("allowing time for binaries", result.stdout)
        self.assertNotIn("git push", self.log.read_text())

    def test_signed_binaries_convert_source_formula(self):
        self.env["ONLY"] = "filefacts"
        result = self.run_bump([release("v3.0.0", Path("filefacts.rb"))])
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        updated = (self.work / "Formula/filefacts.rb").read_text()
        self.assertEqual(current_tag(updated), "v3.0.0")
        self.assertIn('bin.install "filefacts"', updated)
        self.assertNotIn("revision:", updated)
        self.assertIn("git push", self.log.read_text())


if __name__ == "__main__":
    unittest.main()
