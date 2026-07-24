# Atomdrift Tap

## How do I install these formulae?

Since this tap is hosted on Codeberg, add it with the full URL:

```bash
brew tap atomdrift/tap https://github.com/atomdrift-project/homebrew-tap.git
```

Then install formulas:

```bash
brew install atomdrift/tap/stng
brew install atomdrift/tap/cleave
brew install atomdrift/tap/scan
```

Or in a `brew bundle` `Brewfile`:

```ruby
tap "atomdrift/tap", "https://github.com/atomdrift-project/homebrew-tap.git"
brew "stng"
brew "cleave"
brew "scan"
```

## Formulas

- **stng** - Language-aware string extraction for Go and Rust binaries
- **cleave** - AST-aware software decomposition and deep static binary analysis
- **scan** - Context-free malware detection using ML and cleave static analysis

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
