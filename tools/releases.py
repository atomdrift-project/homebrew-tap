"""Release naming and version ordering shared by discovery and upgrades."""

import re
from pathlib import Path

TARGETS = (
    "aarch64-apple-darwin",
    "x86_64-apple-darwin",
    "aarch64-unknown-linux-musl",
    "x86_64-unknown-linux-musl",
)
TAG_RE = re.compile(
    r"v?(\d+)\.(\d+)\.(\d+)(?:-([0-9A-Za-z.-]+))?(?:\+[0-9A-Za-z.-]+)?"
)
URL_RE = re.compile(
    r'^(?P<indent> *)url "https://github.com/(?P<repo>[^/]+/[^/]+)'
    r'/releases/download/(?P<tag>[^/]+)/(?P<asset>[^\"]+)"$',
    re.MULTILINE,
)


def version_key(tag: str) -> tuple:
    """Compare numeric versions, including SemVer prerelease identifiers."""
    match = TAG_RE.fullmatch(tag)
    if not match:
        raise ValueError(f"unsupported release tag: {tag}")
    major, minor, patch, prerelease = match.groups()
    identifiers = tuple(
        (0, int(part)) if part.isdigit() else (1, part)
        for part in (prerelease or "").split(".")
    )
    return int(major), int(minor), int(patch), prerelease is None, identifiers


def binary_name(path: Path) -> str:
    return "atomscan" if path.stem == "scan" else path.stem


def asset_names(path: Path, tag: str) -> list[str]:
    version_key(tag)
    version = tag.removeprefix("v")
    return [f"{binary_name(path)}-{version}-{target}.tar.gz" for target in TARGETS]


def current_tag(text: str) -> str:
    urls = list(URL_RE.finditer(text))
    if urls:
        tags = {match["tag"] for match in urls}
        if len(tags) != 1:
            raise ValueError("formula has inconsistent binary release versions")
        return tags.pop()
    match = re.search(r'tag:\s*"([^\"]+)"', text)
    if not match:
        raise ValueError("formula has no pinned release")
    return match[1]
