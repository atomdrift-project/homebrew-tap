#!/usr/bin/env python3
"""Upgrade or convert a formula using a release's verified SHA256SUMS."""

import re
import subprocess
import sys
from pathlib import Path

from releases import URL_RE, asset_names, binary_name, current_tag, version_key

SHA_RE = re.compile(r'(?P<indent> *)sha256 "[0-9a-f]{64}"')


def parse_sums(text: str, origin: str) -> dict[str, str]:
    sums = {}
    for line in text.splitlines():
        if not line.strip():
            continue
        match = re.fullmatch(r"([0-9a-fA-F]{64})\s+\*?(?:\./)?([^\s/]+)", line)
        if not match:
            raise ValueError(f"{origin}: invalid checksum line: {line}")
        digest, asset = match.groups()
        if asset in sums:
            raise ValueError(f"{origin}: duplicate checksum for {asset}")
        sums[asset] = digest.lower()
    if not sums:
        raise ValueError(f"{origin} is empty")
    return sums


def sha256sums(repo: str, tag: str) -> dict[str, str]:
    proc = subprocess.run(
        ["gh", "release", "download", tag, "--repo", repo,
         "--pattern", "SHA256SUMS", "-O", "-"],
        stdout=subprocess.PIPE, text=True, check=True,
    )
    return parse_sums(proc.stdout, f"{repo} {tag} SHA256SUMS")


def convert_source(text: str, path: Path, repo: str, tag: str,
                   sums: dict[str, str]) -> str:
    source = re.compile(
        r'^  url "https://github.com/' + re.escape(repo) + r'\.git",\n'
        r'      tag:\s*"[^\"]+",\n      revision:\s*"[a-f0-9]+"\n', re.MULTILINE,
    )
    text, count = source.subn("", text)
    if count != 1:
        raise ValueError("expected one pinned source URL")
    head = f'  head "https://github.com/{repo}.git", branch: "main"\n\n  depends_on "rust" => :build'
    if head not in text:
        raise ValueError("expected a source HEAD and Rust build dependency")
    text = text.replace(head, f'''
  head do
    url "https://github.com/{repo}.git", branch: "main"

    depends_on "rust" => :build
  end
''', 1)
    blocks = []
    names = asset_names(path, tag)
    for platform, assets in (("macos", names[:2]), ("linux", names[2:])):
        if platform == "linux":
            blocks.append("  # Static musl binaries avoid host glibc and libstdc++ requirements.\n")
        blocks.append(f"  on_{platform} do\n")
        for arch, asset in zip(("arm", "intel"), assets):
            blocks.append(f'''    on_{arch} do
      url "https://github.com/{repo}/releases/download/{tag}/{asset}"
      sha256 "{sums[asset]}"
    end
''')
        blocks.append("  end\n\n")
    install = '''  def install
    system "cargo", "install", *std_cargo_args
  end'''
    if install not in text:
        raise ValueError("expected a Cargo install method")
    return text.replace(install, "".join(blocks) + f'''  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "{binary_name(path)}"
    end
  end''', 1)


def upgrade(text: str, path: Path, repo: str, tag: str,
            sums: dict[str, str]) -> str:
    version_key(tag)
    missing = set(asset_names(path, tag)) - sums.keys()
    if missing:
        raise ValueError(f"{repo} {tag} is missing checksums for: {', '.join(sorted(missing))}")
    old_key = version_key(current_tag(text))
    if version_key(tag) > old_key:
        # Homebrew revisions only distinguish packages within the same version.
        text = re.sub(r"^  revision \d+\n", "", text, flags=re.MULTILINE)
    if not URL_RE.search(text):
        if version_key(tag) == old_key:
            # Existing source installations must upgrade to the binary package.
            revision = re.search(r"^  revision (\d+)\n", text, re.MULTILINE)
            number = int(revision[1]) + 1 if revision else 1
            text = re.sub(r"^  revision \d+\n", "", text, flags=re.MULTILINE)
            text = re.sub(r'(^  license [^\n]+\n)', rf'\g<1>  revision {number}\n',
                          text, count=1, flags=re.MULTILINE)
        return convert_source(text, path, repo, tag, sums)

    # Match the adjacent checksum, never one from a different platform.
    pair = re.compile(URL_RE.pattern.removesuffix("$") + r'\n(?P<sha_line> *sha256 "[0-9a-f]{64}")', re.MULTILINE)
    rewritten = []

    def replace(match: re.Match) -> str:
        if match["repo"] != repo:
            raise ValueError(f"unexpected release repository: {match['repo']}")
        old_version = match["tag"].removeprefix("v")
        prefix = f"{binary_name(path)}-{old_version}-"
        if not match["asset"].startswith(prefix):
            raise ValueError(f"unexpected asset name: {match['asset']}")
        asset = f"{binary_name(path)}-{tag.removeprefix('v')}-" + match["asset"][len(prefix):]
        if asset not in sums:
            raise ValueError(f"{repo} {tag} has no checksum for {asset}")
        rewritten.append(asset)
        sha = SHA_RE.fullmatch(match["sha_line"])
        return (f'{match["indent"]}url "https://github.com/{repo}/releases/download/{tag}/{asset}"\n'
                f'{sha["indent"]}sha256 "{sums[asset]}"')

    updated = pair.sub(replace, text)
    expected = set(asset_names(path, tag))
    if (len(rewritten) != len(expected) or len(rewritten) != len(list(URL_RE.finditer(text)))
            or set(rewritten) != expected):
        raise ValueError("expected four platform URLs with adjacent checksums")
    return updated


def main() -> None:
    if len(sys.argv) not in (4, 5):
        raise SystemExit("usage: upgrade-binary.py <formula.rb> <repo> <TAG> [SHA256SUMS]")
    path, repo, tag = Path(sys.argv[1]), sys.argv[2], sys.argv[3]
    # CI passes the exact bytes verified by cosign, avoiding an unverified refetch.
    try:
        sums = (parse_sums(Path(sys.argv[4]).read_text(), sys.argv[4])
                if len(sys.argv) == 5 else sha256sums(repo, tag))
        updated = upgrade(path.read_text(), path, repo, tag, sums)
    except (ValueError, subprocess.CalledProcessError) as exc:
        raise SystemExit(f"error: {exc}") from exc
    path.write_text(updated)
    print(f"Updated {path} to {tag} (binary).")


if __name__ == "__main__":
    main()
