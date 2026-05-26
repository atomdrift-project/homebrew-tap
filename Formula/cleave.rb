class Cleave < Formula
  desc "AST-aware software decomposition and deep static binary analysis"
  homepage "https://codeberg.org/atomdrift/cleave"

  url "https://codeberg.org/atomdrift/cleave.git",
      tag:      "v2.0.0-rc.2",
      revision: "b065f972cb0b3459b34c1e96647ccecafe5089eb"
  license "Apache-2.0"
  head "https://codeberg.org/atomdrift/cleave.git", branch: "main"

  depends_on "rust" => :build
  depends_on "rizin" => :recommended
  depends_on "upx" => :recommended

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "cleave", shell_output("#{bin}/cleave --help")
  end
end
