class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://codeberg.org/atomdrift/filefacts"

  url "https://codeberg.org/atomdrift/filefacts.git",
      tag:      "v1.1.1",
      revision: "8a41644aca3c440084bc025921d4dbca5cd37a3d"
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
