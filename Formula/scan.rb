class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://codeberg.org/atomdrift/scan"

  url "https://codeberg.org/atomdrift/scan.git",
      tag:      "v2.1.2",
      revision: "6bc3cfe40520b5a05aa00ce1825e8c2adcebb90a"
  license "Apache-2.0"
  head "https://codeberg.org/atomdrift/scan.git", branch: "main"

  depends_on "rust" => :build
  depends_on "atomdrift/tap/cleave"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "ascan", shell_output("#{bin}/ascan --help")
  end
end
