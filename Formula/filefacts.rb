class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://github.com/atomdrift-project/filefacts"

  url "https://github.com/atomdrift-project/filefacts.git",
      tag:      "v2.0.1",
      revision: "ed1f6d0721dd71324a1e6913709231390996ce8c"
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
