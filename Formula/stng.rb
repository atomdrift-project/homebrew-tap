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
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.0/stng-3.0.0-aarch64-apple-darwin.tar.gz"
      sha256 "21d929f93e86b8917e1b9d241f849d925c0fded0e3ac061d2f475fc08f3d62b8"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.0/stng-3.0.0-x86_64-apple-darwin.tar.gz"
      sha256 "5988fea05779a882ad5bb45fb45e27426edaa603218e1c698515ca48d89f9aa5"
    end
  end

  # Static musl binaries avoid host glibc and libstdc++ requirements.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.0/stng-3.0.0-aarch64-unknown-linux-musl.tar.gz"
      sha256 "4f1a8096fd2cdd82e0ff587cc98f0e111d67038636487f16cac8eb052faa68bf"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.0/stng-3.0.0-x86_64-unknown-linux-musl.tar.gz"
      sha256 "87f1dceeb7dbde862be7cd44161c36351bac2f96345e91925329fc932478bdef"
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
