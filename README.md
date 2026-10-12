# Atomdrift Tap

## How do I install these formulae?

Install any formula directly. Homebrew adds the tap automatically before installing the selected formula:

```bash
brew install atomdrift-project/tap/stng
brew install atomdrift-project/tap/cleave
brew install atomdrift-project/tap/filefacts
brew install atomdrift-project/tap/scan
brew install atomdrift-project/tap/isomer
brew install atomdrift-project/tap/hood
```

Or in a `brew bundle` `Brewfile`:

```ruby
tap "atomdrift-project/tap"
brew "stng"
brew "cleave"
brew "filefacts"
brew "scan"
brew "isomer"
brew "hood"
```

## Formulas

- **stng** - Language-aware string extraction for Go and Rust binaries
- **cleave** - AST-aware software decomposition and deep static binary analysis
- **filefacts** - Structured file facts for feature extraction and automation
- **scan** - Context-free malware detection using ML and cleave static analysis
- **isomer** - Supply-chain attack detection at a molecular level
- **hood** - Scan HTTP(S) payloads before they reach package managers and installers

`stng`, `cleave`, `scan`, and `isomer` install upstream binary releases on Intel
and ARM macOS and Linux. Linux uses static musl builds. Rust is only required
when installing these tools with `--HEAD`.

`filefacts` and `hood` still build from source because their published releases
have no binaries. The bump automation switches them to binaries once upstream
publishes all four platform archives and signed checksums.

## Release automation

GitHub Actions checks upstream releases twice an hour. It fetches release
metadata in pages of 100, compares numeric versions (including prereleases),
and selects the highest version with all four archives, `SHA256SUMS`, and its
Sigstore bundle. Incomplete newer releases do not block a complete older
release, and formulas never downgrade. API failures fail the run visibly.

Before updating or converting a formula, CI verifies the checksum signature
against the upstream release workflow and passes that exact manifest to
`make upgrade`. Projects with no published binaries retain source builds;
new source releases wait six hours to allow a binary build to finish.

Run `make automation-test` for the offline release-selection and upgrade tests.
GitHub Actions also checks formula style, audits dependencies, and installs
and tests the binary formulas on macOS and Linux.

## Recommended extraction tools

`cleave` shells out to these for deeper analysis; they are `:recommended`, so
a normal install pulls them in:

```bash
brew install sevenzip rizin upx
```

Use `sevenzip` (binary `7zz`), not `p7zip` — p7zip's `7z` cannot read APFS,
so `.dmg` contents go unscanned.

`scan`, `isomer`, and `hood` use the same extraction tools. `stng` and
`filefacts` recommend `rizin` for deeper binary analysis.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
