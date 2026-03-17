# Atomdrift Tap

## How do I install these formulae?

Since this tap is hosted on Codeberg, add it with the full URL:

```bash
brew tap atomdrift/tap https://codeberg.org/atomdrift/homebrew-tap.git
```

Then install formulas:

```bash
brew install atomdrift/tap/stng
brew install atomdrift/tap/cleave
brew install atomdrift/tap/litmus
```

Or in a `brew bundle` `Brewfile`:

```ruby
tap "atomdrift/tap", "https://codeberg.org/atomdrift/homebrew-tap.git"
brew "stng"
brew "cleave"
brew "litmus"
```

## Formulas

- **stng** - Language-aware string extraction for Go and Rust binaries
- **cleave** - AST-aware software decomposition and deep static binary analysis
- **litmus** - ML-powered malware classification using cleave static analysis

## Documentation

`brew help`, `man brew` or check [Homebrew's documentation](https://docs.brew.sh).
