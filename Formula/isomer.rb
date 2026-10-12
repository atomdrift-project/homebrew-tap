class Isomer < Formula
  desc "Supply-chain attack detection at a molecular level"
  homepage "https://github.com/atomdrift-project/isomer"

  license "Apache-2.0"
  revision 1

  head do
    url "https://github.com/atomdrift-project/isomer.git", branch: "main"

    depends_on "rust" => :build
  end

  # isomer links cleave as a library, so the cleave CLI is not required -- but
  # the analyzers it embeds still shell out to these tools.
  depends_on "rizin" => :recommended
  # Upstream 7-Zip (`7zz`), not `p7zip`: p7zip's `7z` has no APFS handler, so
  # .dmg contents go unscanned. cleave prefers `7zz` and falls back to `7z`.
  depends_on "sevenzip" => :recommended
  depends_on "upx" => :recommended

  on_macos do
    on_arm do
      url "https://github.com/atomdrift-project/isomer/releases/download/v0.5.0/isomer-0.5.0-aarch64-apple-darwin.tar.gz"
      sha256 "db8694700dbf10e34a76406520cbac8d46d720da261bf9bb531b383fbbee8455"
    end
    on_intel do
      url "https://github.com/atomdrift-project/isomer/releases/download/v0.5.0/isomer-0.5.0-x86_64-apple-darwin.tar.gz"
      sha256 "1bc55a5ce79d00030f9a1e8c7cefa1818252251f0d1d488cd122bb0af28b569a"
    end
  end

  # Static musl binaries avoid host glibc and libstdc++ requirements.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/isomer/releases/download/v0.5.0/isomer-0.5.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "b72212062d3a20205d44a665459713b0c6858af0a0efe17ea19ff28ed004de56"
    end
    on_intel do
      url "https://github.com/atomdrift-project/isomer/releases/download/v0.5.0/isomer-0.5.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "e4758c98f9587dd37d54b26b9b58882416c8925e912640bbf106f80bd564cce5"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "isomer"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/isomer --version")
  end
end
