class Filefacts < Formula
  desc "Extracts file facts: identification, structure, strings, metrics, symbols, AST"
  homepage "https://github.com/atomdrift-project/filefacts"

  url "https://github.com/atomdrift-project/filefacts.git",
      tag:      "v1.7.0",
      revision: "7025322aab2f2a7b1755645cdd078a4cbaf72c0f"
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
