#!/usr/bin/env python3
"""Point a binary-release formula at a new upstream version.

Rewrites every `url` line that refers to a GitHub release asset, then replaces
the `sha256` line that follows it with the checksum upstream published in that
release's SHA256SUMS. Formulas that build from source (`tag:`/`revision:`) are
handled by `make upgrade` directly and never reach this script.
"""

import re
import subprocess
import sys

URL_RE = re.compile(r'^(?P<indent>\s*)url "(?P<url>[^"]*/releases/download/[^"]+)"')
SHA_RE = re.compile(r'^(?P<indent>\s*)sha256 "(?P<sha>[0-9a-f]{64})"')
# The version appears twice in an asset URL: the tag (/v2.5.0/) and the
# filename (atomscan-2.5.0-x86_64-...). Both must move together.
TAG_RE = re.compile(r"/v\d+\.\d+\.\d+/")
FILE_VER_RE = re.compile(r"-\d+\.\d+\.\d+-")


def parse_sums(text: str, origin: str) -> dict[str, str]:
    """Return {asset name: sha256} from SHA256SUMS content."""
    sums = {}
    for line in text.splitlines():
        parts = line.split()
        if len(parts) == 2:
            sums[parts[1].lstrip("./")] = parts[0]
    if not sums:
        raise SystemExit(f"error: {origin} is empty")
    return sums


def sha256sums(repo: str, tag: str) -> dict[str, str]:
    """Return {asset name: sha256} from the release's SHA256SUMS asset."""
    proc = subprocess.run(
        ["gh", "release", "download", tag, "--repo", repo,
         "--pattern", "SHA256SUMS", "-O", "-"],
        capture_output=True, text=True,
    )
    if proc.returncode != 0:
        raise SystemExit(
            f"error: could not fetch SHA256SUMS from {repo} {tag}\n"
            f"  {proc.stderr.strip()}\n"
            f"  (releases without prebuilt assets must be pinned by tag/revision instead)"
        )
    return parse_sums(proc.stdout, f"{repo} {tag} SHA256SUMS")


def main() -> None:
    if len(sys.argv) not in (4, 5):
        raise SystemExit(
            "usage: upgrade-binary.py <formula.rb> <repo> <vTAG> [SHA256SUMS]"
        )
    path, repo, tag = sys.argv[1:4]
    version = tag.lstrip("v")

    # A caller that has already verified a SHA256SUMS -- CI checks the cosign
    # bundle upstream publishes beside it -- passes that exact file, so the
    # checksums written here are the bytes that were verified rather than a
    # second, unverified fetch of the same asset.
    if len(sys.argv) == 5:
        local = sys.argv[4]
        sums = parse_sums(open(local).read(), local)
    else:
        sums = sha256sums(repo, tag)
    lines = open(path).read().splitlines(keepends=True)

    rewritten = 0
    for i, line in enumerate(lines):
        m = URL_RE.match(line)
        if not m:
            continue
        url = TAG_RE.sub(f"/v{version}/", m["url"])
        url = FILE_VER_RE.sub(f"-{version}-", url)
        asset = url.rsplit("/", 1)[1]
        if asset not in sums:
            raise SystemExit(f"error: {repo} {tag} has no asset named {asset}")

        # The sha256 for an asset is the next sha256 line after its url.
        for j in range(i + 1, len(lines)):
            s = SHA_RE.match(lines[j])
            if s:
                lines[j] = f'{s["indent"]}sha256 "{sums[asset]}"\n'
                break
        else:
            raise SystemExit(f"error: no sha256 line follows the url for {asset}")

        lines[i] = f'{m["indent"]}url "{url}"\n'
        rewritten += 1
        print(f"  {asset}")

    if not rewritten:
        raise SystemExit(f"error: {path} has no release-asset url lines")

    open(path, "w").write("".join(lines))
    print(f"Updated {rewritten} asset(s) to {version}.")


if __name__ == "__main__":
    main()
