class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://codeberg.org/atomdrift/scan"

  url "https://codeberg.org/atomdrift/scan.git",
      tag:      "v2.1.0",
      revision: "9ba20432c9dd4c4670d4038e4dbde8c8a17af60f"
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
