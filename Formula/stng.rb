class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://github.com/atomdrift-project/stng"

  license "Apache-2.0"
  revision 1

  head do
    url "https://github.com/atomdrift-project/stng.git", branch: "main"

    depends_on "rust" => :build
  end

  # Optional disassembler integration enables deeper extraction and --xorscan.
  depends_on "rizin" => :recommended

  on_macos do
    on_arm do
      url "https://github.com/atomdrift-project/stng/releases/download/v2.1.1/stng-2.1.1-aarch64-apple-darwin.tar.gz"
      sha256 "9d082707b00240fd66a0b54451acadb6013cdc1b979ce17b0b0e44a10538ed11"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v2.1.1/stng-2.1.1-x86_64-apple-darwin.tar.gz"
      sha256 "3f0d223b55f83803612dbe3586cebbc27a020e8641fbb7100aac87e508c350e6"
    end
  end

  # Static musl binaries avoid host glibc and libstdc++ requirements.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/stng/releases/download/v2.1.1/stng-2.1.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "0cf6b0c17b335da29586e22e97577cfd0b20a8ca0bf2fabf591a5abc26a88fe4"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v2.1.1/stng-2.1.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "0c50810d418ac60015f4f3f57a3ab9f374059601c601995cc57ce1b2b5fb3424"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "stng"
    end
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/stng --version")
  end
end
