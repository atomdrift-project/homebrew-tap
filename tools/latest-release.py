#!/usr/bin/env python3
"""Select the highest complete binary release, without trusting /latest."""

import json
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

from releases import URL_RE, asset_names, current_tag, version_key


def select_release(path: Path, text: str, releases: list[dict]) -> dict:
    current = version_key(current_tag(text))
    published = []
    for release in releases:
        if release["draft"]:
            continue
        try:
            key = version_key(release["tag_name"])
        except ValueError:
            continue
        published.append((key, release))
    published.sort(key=lambda item: (item[0], item[1]["published_at"]), reverse=True)
    if not published:
        return {"status": "none", "tag": ""}

    newest = published[0][1]
    age = int((datetime.now(timezone.utc) - datetime.fromisoformat(
        newest["published_at"].replace("Z", "+00:00")
    )).total_seconds() // 60)
    result = {"latest": newest["tag_name"], "age": age, "tag": ""}
    binary = bool(URL_RE.search(text))
    for key, release in published:
        if key < current:
            break
        required = set(asset_names(path, release["tag_name"])) | {
            "SHA256SUMS", "SHA256SUMS.sigstore.json",
        }
        uploaded = {asset["name"] for asset in release["assets"]
                    if asset.get("state") == "uploaded" and asset.get("size", 0) > 0}
        if required <= uploaded:
            # Include prereleases, as before; version precedence is explicit.
            return result | {"status": "ok" if binary and key == current else "bump",
                             "mode": "binary", "tag": release["tag_name"]}

    if binary:
        return result | {"status": "wait", "mode": "binary"}
    # A project with a binary pipeline must wait for its complete signed set.
    if any(asset["name"].endswith(".tar.gz") for _, release in published
           for asset in release["assets"]):
        return result | {"status": "wait", "mode": "binary"}
    return result | {"status": "ok" if published[0][0] <= current else "bump",
                     "mode": "source", "tag": current_tag(text) if published[0][0] <= current
                     else newest["tag_name"]}


def main() -> None:
    if len(sys.argv) != 3:
        raise SystemExit("usage: latest-release.py <formula.rb> <owner/repo>")
    path = Path(sys.argv[1])
    # Usually one request per tool. Pagination removes the old 20-release cap;
    # sorting handles backfills and GitHub's manually assigned latest flag.
    proc = subprocess.run(
        ["gh", "api", f"repos/{sys.argv[2]}/releases?per_page=100", "--paginate", "--slurp"],
        stdout=subprocess.PIPE, text=True, check=True,
    )
    releases = [release for page in json.loads(proc.stdout) for release in page]
    print(json.dumps(select_release(path, path.read_text(), releases)))


if __name__ == "__main__":
    main()
