class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://github.com/atomdrift-project/scan"

  url "https://github.com/atomdrift-project/scan.git",
      tag:      "v2.5.0",
      revision: "002c2ea4b8238d1599edc031af58e57233a570fe"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/scan.git", branch: "main"

  depends_on "rust" => :build
  depends_on "atomdrift/tap/cleave"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "atomscan", shell_output("#{bin}/atomscan --help")
  end
end
