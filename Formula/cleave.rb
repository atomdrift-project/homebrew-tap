class Cleave < Formula
  desc "AST-aware software decomposition and deep static binary analysis"
  homepage "https://github.com/atomdrift-project/cleave"

  url "https://github.com/atomdrift-project/cleave.git",
      tag:      "v2.3.0",
      revision: "1435c586cf26cee4723905b757afb692c1402995"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/cleave.git", branch: "main"

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
