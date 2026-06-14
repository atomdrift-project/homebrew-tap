class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://codeberg.org/atomdrift/filefacts"

  url "https://codeberg.org/atomdrift/filefacts.git",
      tag:      "v1.0.1",
      revision: "3f714d86cca8673ae22d4801e8231d186a1990db"
  license "Apache-2.0"
  head "https://codeberg.org/atomdrift/filefacts.git", branch: "main"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "filefacts", shell_output("#{bin}/filefacts --help")
  end
end
