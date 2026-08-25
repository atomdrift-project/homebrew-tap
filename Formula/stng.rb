class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://github.com/atomdrift-project/stng"

  url "https://github.com/atomdrift-project/stng.git",
      tag:      "v1.9.1",
      revision: "9eceb4b85fc270e61bb8e0e247113a79c07a49ef"
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
