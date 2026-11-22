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
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.1.0/cleave-3.1.0-aarch64-apple-darwin.tar.gz"
      sha256 "e6ce2065d3b09f2d40a16f28fff27a0c389d224dbe9f63677ebe512a8905faae"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.1.0/cleave-3.1.0-x86_64-apple-darwin.tar.gz"
      sha256 "4bdef62719ee25204aa9166df66b6b9a8a1e764fadd04285b9b181721f1a0f94"
    end
  end

  # musl, not gnu -- see the note in scan.rb. The gnu builds carry a GLIBC_2.34
  # floor and a libstdc++ dependency; the musl ones are static with no floor.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.1.0/cleave-3.1.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "2fc54f27f54b4bfc2adf74bdde4b4d062cb960e74c0804661862e067c13c2c03"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.1.0/cleave-3.1.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "d65ce018ad6cafac1ad3a658587d80e4f4ad660e732c279cef710cf41d8fbf53"
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
