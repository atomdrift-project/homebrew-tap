class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://codeberg.org/atomdrift/scan"

  url "https://codeberg.org/atomdrift/scan.git",
      tag:      "v2.2.0",
      revision: "c8f9b6044d061734aea1cc0c4a36b0363e6d5e7d"
  license "Apache-2.0"
  head "https://codeberg.org/atomdrift/scan.git", branch: "main"

  depends_on "rust" => :build
  depends_on "atomdrift/tap/cleave"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "atomscan", shell_output("#{bin}/atomscan --help")
  end
end
