class Cleave < Formula
  desc "AST-aware software decomposition and deep static binary analysis"
  homepage "https://github.com/atomdrift-project/cleave"

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
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.12.1/cleave-2.12.1-aarch64-apple-darwin.tar.gz"
      sha256 "b6263c33a5951415f27c2d5a73bce9e0cadae5d8fceeff9cb50a79688aa00540"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.12.1/cleave-2.12.1-x86_64-apple-darwin.tar.gz"
      sha256 "919cf9b2387425427abda74b90e85bae282efe2b359d7f126659cb306e0d04a4"
    end
  end

  # musl, not gnu -- see the note in scan.rb. The gnu builds carry a GLIBC_2.34
  # floor and a libstdc++ dependency; the musl ones are static with no floor.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.12.1/cleave-2.12.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "f95c4299b6b7009fadcb4b72b4a32d2d37cbcd95d0d24187fd8f7e10d7af1528"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v2.12.1/cleave-2.12.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "19437bafa19e56845a011d6af2bfd6d0db2dc53d192963038c85124af1003543"
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
