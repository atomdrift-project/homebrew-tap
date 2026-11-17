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
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.0.0/cleave-3.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "0037c5366a9afb8e787c2f368518b5ecd7619acd08c6c7e4c9802bd47477d560"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.0.0/cleave-3.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "d2768d3d4a0016cf92350887082c42b10b4d639f79056bf3fe934db7764ebc1b"
    end
  end

  # musl, not gnu -- see the note in scan.rb. The gnu builds carry a GLIBC_2.34
  # floor and a libstdc++ dependency; the musl ones are static with no floor.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.0.0/cleave-3.0.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "5683e1e378f516af92eb776f798fe2ae462aadf76647855f2cc5a84f4b2a29b5"
    end
    on_intel do
      url "https://github.com/atomdrift-project/cleave/releases/download/v3.0.0/cleave-3.0.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "dbeabd55d0dd718680d7ec97e6c62663900e24e71e62aa92958cdad71d26318f"
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
