class Cleave < Formula
  desc "AST-aware software decomposition and deep static binary analysis"
  homepage "https://codeberg.org/atomdrift/cleave"

  url "https://codeberg.org/atomdrift/cleave.git",
      tag:      "v2.2.0",
      revision: "2577805e2b4265ded18b0b3155c2fdadce18b050"
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
