class Litmus < Formula
  desc "ML-powered malware classification using cleave static analysis"
  homepage "https://codeberg.org/atomdrift/litmus"

  url "https://codeberg.org/atomdrift/litmus.git",
      tag:      "v2.0.0-rc.3",
      revision: "71d8bc00006714f1b0376f4a6d9b978394ce792a"
  license "Apache-2.0"
  head "https://codeberg.org/atomdrift/litmus.git", branch: "main"

  depends_on "rust" => :build
  depends_on "atomdrift/tap/cleave"

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "litmus", shell_output("#{bin}/litmus --help")
  end
end
