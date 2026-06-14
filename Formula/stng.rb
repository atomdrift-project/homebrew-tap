class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://codeberg.org/atomdrift/stng"

  url "https://codeberg.org/atomdrift/stng.git",
      tag:      "v1.6.2",
      revision: "3b9adc200726da82bc45ea72539fc4e24893378b"
  license "Apache-2.0"
  head "https://codeberg.org/atomdrift/stng.git", branch: "main"

  depends_on "rust" => :build
  depends_on "rizin"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/stng --version")
  end
end
