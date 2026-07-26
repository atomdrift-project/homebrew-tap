class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://github.com/atomdrift-project/scan"

  url "https://github.com/atomdrift-project/scan.git",
      tag:      "v2.4.0",
      revision: "453c720ff46f635f6e1ff566f2c963edeebda197"
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
