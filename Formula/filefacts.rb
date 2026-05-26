class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://codeberg.org/atomdrift/filefacts"

  url "https://codeberg.org/atomdrift/filefacts.git",
      tag:      "v0.7.0",
      revision: "f624200cc8388c341c6cf94fc2220795b1433c2a"
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
