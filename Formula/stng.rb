class Stng < Formula
  desc "Language-aware string extraction for Go and Rust binaries"
  homepage "https://codeberg.org/atomdrift/stng"

  url "https://codeberg.org/atomdrift/stng.git",
      tag:      "v1.5.0",
      revision: "bc43028b835a9b7e608588cab26dae30c4afde95"
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
