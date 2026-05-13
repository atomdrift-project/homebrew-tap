class Litmus < Formula
  desc "ML-powered malware classification using cleave static analysis"
  homepage "https://codeberg.org/atomdrift/litmus"

  url "https://codeberg.org/atomdrift/litmus.git",
      tag:      "v1.2.1",
      revision: "b10074a9d13dc91e5134a8f6e9e79811e77285fc"
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
