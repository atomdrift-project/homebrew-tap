class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://github.com/atomdrift-project/filefacts"

  url "https://github.com/atomdrift-project/filefacts.git",
      tag:      "v3.0.0",
      revision: "19467eb03004e70543459e9b8f2927ec156b53e4"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/filefacts.git", branch: "main"

  depends_on "rust" => :build
  # Recover deeper symbols from PE, ELF, and Mach-O files.
  depends_on "rizin" => :recommended

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "filefacts", shell_output("#{bin}/filefacts --help")
  end
end
