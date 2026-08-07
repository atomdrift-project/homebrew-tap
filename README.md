# Atomdrift Tap

## How do I install these formulae?

Install any formula directly. Homebrew adds the tap automatically before installing the selected formula:

```bash
brew install atomdrift-project/tap/stng
brew install atomdrift-project/tap/cleave
brew install atomdrift-project/tap/filefacts
brew install atomdrift-project/tap/scan
```

Or in a `brew bundle` `Brewfile`:

```ruby
tap "atomdrift-project/tap"
brew "stng"
brew "cleave"
brew "filefacts"
brew "scan"
```

## Formulas

- **stng** - Language-aware string extraction for Go and Rust binaries
- **cleave** - AST-aware software decomposition and deep static binary analysis
- **filefacts** - Structured file facts for feature extraction and automation
- **scan** - Context-free malware detection using ML and cleave static analysis

## Recommended extraction tools

`cleave` shells out to these for deeper analysis; they are `:recommended`, so
a normal install pulls them in:

```bash
brew install sevenzip rizin upx
```

Use `sevenzip` (binary `7zz`), not `p7zip` — p7zip's `7z` cannot read APFS,
so `.dmg` contents go unscanned.

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
