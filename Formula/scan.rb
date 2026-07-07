class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://codeberg.org/atomdrift/scan"

  url "https://codeberg.org/atomdrift/scan.git",
      tag:      "v2.2.1",
      revision: "63f7d03940ab6bdceec588371a006f1c6739c3e5"
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
