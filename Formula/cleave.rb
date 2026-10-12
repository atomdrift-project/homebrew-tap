class Cleave < Formula
  desc "AST-aware software decomposition and deep static binary analysis"
  homepage "https://github.com/atomdrift-project/cleave"

  url "https://github.com/atomdrift-project/cleave.git",
      tag:      "v2.12.1",
      revision: "af5baf135f0a92aed33482ae1c492c00882dbc34"
  license "Apache-2.0"

  head do
    url "https://github.com/atomdrift-project/cleave.git", branch: "main"

    depends_on "rust" => :build
  end

  depends_on "rizin" => :recommended
  # Upstream 7-Zip (`7zz`), not `p7zip`: p7zip's `7z` has no APFS handler, so
  # .dmg contents go unscanned. cleave prefers `7zz` and falls back to `7z`.
  depends_on "sevenzip" => :recommended
  depends_on "upx" => :recommended

  on_macos do
    on_arm do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.7.1/cleave-2.7.1-aarch64-apple-darwin.tar.gz"
      sha256 "47a133a820225cd51b7bffb15be723a8d79670e7a0622115f8877b2b5a900fe8"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.7.1/cleave-2.7.1-x86_64-apple-darwin.tar.gz"
      sha256 "f5e5f4d1902042dce285ac85e83a9052823241ab57937c32e262f089540f6ff5"
    end
  end

  # musl, not gnu -- see the note in scan.rb. The gnu builds carry a GLIBC_2.34
  # floor and a libstdc++ dependency; the musl ones are static with no floor.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.7.1/cleave-2.7.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "d2822a163949f501de2a7ec54cc13dc558bdacfcef281909ba967c0e1e0f9224"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.7.1/cleave-2.7.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "1059201f6439f1147ddee0083afefea8c0ee257ddf592d6d4a54e76a1e395602"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "cleave"
    end
  end

  test do
    assert_match "cleave", shell_output("#{bin}/cleave --help")
    assert_match version.to_s, shell_output("#{bin}/cleave --version")
  end
end
