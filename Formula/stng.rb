class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://github.com/atomdrift-project/stng"

  url "https://github.com/atomdrift-project/stng.git",
      tag:      "v1.10.0",
      revision: "0bf74dde9bd065e0cd2385fcf0d1eaf885af56be"
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
