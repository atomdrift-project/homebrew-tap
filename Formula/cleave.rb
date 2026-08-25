class Cleave < Formula
  desc "AST-aware software decomposition and deep static binary analysis"
  homepage "https://github.com/atomdrift-project/cleave"

  url "https://github.com/atomdrift-project/cleave.git",
      tag:      "v2.8.0",
      revision: "95b1b9e04f6e67fb51111da1f1a6da2ba4ca9347"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/cleave.git", branch: "main"

  depends_on "rust" => :build
  depends_on "rizin" => :recommended
  # Upstream 7-Zip (`7zz`), not `p7zip`: p7zip's `7z` has no APFS handler, so
  # .dmg contents go unscanned. cleave prefers `7zz` and falls back to `7z`.
  depends_on "sevenzip" => :recommended
  depends_on "upx" => :recommended

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "cleave", shell_output("#{bin}/cleave --help")
  end
end
