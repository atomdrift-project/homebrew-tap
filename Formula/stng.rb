class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://github.com/atomdrift-project/stng"

  license "Apache-2.0"

  head do
    url "https://github.com/atomdrift-project/stng.git", branch: "main"

    depends_on "rust" => :build
  end

  # Optional disassembler integration enables deeper extraction and --xorscan.
  depends_on "rizin" => :recommended

  on_macos do
    on_arm do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.1/stng-3.0.1-aarch64-apple-darwin.tar.gz"
      sha256 "29448085795b33efd31b32d79bd18e4d11740ed12c0cf400385a278122fbb787"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.1/stng-3.0.1-x86_64-apple-darwin.tar.gz"
      sha256 "d225bbb8ca8aba7f21e9e38900fe3556a1b3f4d1134e85f9d15624bcc0a92fc5"
    end
  end

  # Static musl binaries avoid host glibc and libstdc++ requirements.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.1/stng-3.0.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "1e7b880c768e125a0216957fc94fd480835ae3dd4e1877e68bd4b225715ebf96"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.1/stng-3.0.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "ee645f2779822b6b3a8af6e99d28da39d6b567d92cf43acf954e2d745f22d86d"
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
