class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://github.com/atomdrift-project/stng"

  url "https://github.com/atomdrift-project/stng.git",
      tag:      "v2.1.1",
      revision: "52c2cb7aec71a89e31c76337a8c24c9de5bffb21"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/stng.git", branch: "main"

  depends_on "rust" => :build
  depends_on "rizin"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/stng --version")
  end
end
