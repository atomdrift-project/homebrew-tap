class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://github.com/atomdrift-project/filefacts"

  url "https://github.com/atomdrift-project/filefacts.git",
      tag:      "v1.5.0",
      revision: "d8f48952373e7c02e1210850b8907f7d0f3be445"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/filefacts.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "filefacts", shell_output("#{bin}/filefacts --help")
  end
end
