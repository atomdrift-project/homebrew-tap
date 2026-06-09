class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://codeberg.org/atomdrift/filefacts"

  url "https://codeberg.org/atomdrift/filefacts.git",
      tag:      "v0.9.5",
      revision: "0db575571e884253f26ceb6636207b08513a96bd"
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
