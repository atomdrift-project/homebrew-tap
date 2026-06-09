class Litmus < Formula
  desc "ML-powered malware classification using cleave static analysis"
  homepage "https://codeberg.org/atomdrift/litmus"

  url "https://codeberg.org/atomdrift/litmus.git",
      tag:      "v2.0.0-rc.5",
      revision: "5987783c3cd483e02a12fa0e2626c7bb17fa182c"
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
