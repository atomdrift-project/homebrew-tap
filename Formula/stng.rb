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
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.2/stng-3.0.2-aarch64-apple-darwin.tar.gz"
      sha256 "2da16f547e9addd07a61bf51234a8109c8f02a2447dec324c1f0802d29cfe219"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.2/stng-3.0.2-x86_64-apple-darwin.tar.gz"
      sha256 "4f5cf6cc048284f157576524f40468f69bcf5bed00c58606e5b3d92040116a57"
    end
  end

  # Static musl binaries avoid host glibc and libstdc++ requirements.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.2/stng-3.0.2-aarch64-unknown-linux-musl.tar.gz"
      sha256 "170fc4122f2a0245b8bd2837b3366bc311b4817bc68aae56da97f1b390748508"
    end
    on_intel do
      url "https://github.com/atomdrift-project/stng/releases/download/v3.0.2/stng-3.0.2-x86_64-unknown-linux-musl.tar.gz"
      sha256 "03e0ad76a5a3c71dd52bdb545e53929045ae48de99ef0b7c69db433358d6fc92"
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
