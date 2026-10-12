#!/usr/bin/env bash
# Discovery is read-only; signatures are checked before make changes any formula.
set -euo pipefail

formulas="$(make -s formulas)"
if [ -n "$ONLY" ] && ! [[ " $formulas " == *" $ONLY "* ]]; then
  echo "::error::unknown formula: $ONLY"
  exit 1
fi

git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'

work_dir="$(mktemp -d)"
trap 'rm -rf "$work_dir"' EXIT
changed=""
skipped=""

for f in $formulas; do
  if [ -n "$ONLY" ] && [ "$ONLY" != "$f" ]; then
    continue
  fi
  repo="atomdrift-project/$f"
  # API/auth/network failures fail the run instead of masquerading as no releases.
  meta="$(python3 tools/latest-release.py "Formula/$f.rb" "$repo")"
  status="$(jq -r '.status' <<< "$meta")"
  if [ "$status" = none ]; then
    echo "skip    $f - no versioned releases published"
    continue
  fi
  tag="$(jq -r '.tag' <<< "$meta")"
  latest="$(jq -r '.latest' <<< "$meta")"
  age="$(jq -r '.age' <<< "$meta")"
  mode="$(jq -r '.mode' <<< "$meta")"
  if [ "$mode" = binary ] && [ "$latest" != "$tag" ]; then
    skipped="$skipped $f@$latest"
    if [ "$age" -ge "$STUCK_WARN_MINUTES" ]; then
      echo "::warning::$f $latest is ${age}m old without a complete signed binary set"
    else
      echo "wait    $f - $latest is awaiting a complete signed binary set"
    fi
  fi
  if [ "$status" = wait ]; then
    continue
  fi
  if [ "$status" = ok ]; then
    echo "ok      $f - already at $tag ($mode)"
    continue
  fi

  if [ "$mode" = source ]; then
    if [ "$age" -lt "$SOURCE_GATE_MINUTES" ]; then
      echo "wait    $f - $tag is ${age}m old, allowing time for binaries to land"
      skipped="$skipped $f@$tag"
      continue
    fi
    make upgrade FORMULA="$f" VERSION="$tag"
  else
    sums_dir="$work_dir/$f"
    mkdir "$sums_dir"
    if ! gh release download "$tag" --repo "$repo" \
        --pattern SHA256SUMS --pattern SHA256SUMS.sigstore.json --dir "$sums_dir"; then
      echo "::warning::$f $tag checksum assets could not be downloaded; retry next run"
      skipped="$skipped $f@$tag"
      continue
    fi
    # Recovery dispatches sign from main. Escape the whole repo/tag identity.
    identity="$(python3 -c 'import re,sys; prefix="https://github.com/"+sys.argv[1]+"/.github/workflows/release.yml@refs/"; print("^"+re.escape(prefix)+"(tags/"+re.escape(sys.argv[2])+"|heads/main)$")' "$repo" "$tag")"
    if ! cosign verify-blob "$sums_dir/SHA256SUMS" \
        --bundle "$sums_dir/SHA256SUMS.sigstore.json" \
        --certificate-identity-regexp "$identity" \
        --certificate-oidc-issuer https://token.actions.githubusercontent.com; then
      echo "::error::$f $tag failed signature verification - refusing to bump"
      exit 1
    fi
    make upgrade FORMULA="$f" VERSION="$tag" SUMS="$sums_dir/SHA256SUMS"
  fi
  brew style "Formula/$f.rb"
  git add "Formula/$f.rb"
  changed="$changed $f@$tag($mode)"
  echo "bumped  $f -> $tag ($mode)"
done

{
  echo "### Formula bump"
  echo
  [ -n "$changed" ] && echo "- Bumped:$changed" || echo "- Bumped: nothing"
  [ -n "$skipped" ] && echo "- Awaiting assets:$skipped" || true
} >> "$GITHUB_STEP_SUMMARY"

if [ -z "$changed" ]; then
  echo "no formulas to bump"
  exit 0
fi
git commit -m "bump:$changed"
for attempt in 1 2 3; do
  if git push; then
    exit 0
  fi
  echo "push rejected, rebasing (attempt $attempt)"
  if ! git pull --rebase; then
    git rebase --abort || true
    echo "::error::rebase conflict against main - resolve by hand"
    exit 1
  fi
done
echo "::error::could not push after 3 attempts"
exit 1
