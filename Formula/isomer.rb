class Isomer < Formula
  desc "Supply-chain attack detection at a molecular level"
  homepage "https://github.com/atomdrift-project/isomer"

  url "https://github.com/atomdrift-project/isomer.git",
      tag:      "v0.4.1",
      revision: "a847e065bccc39fa61be1829b8bdd923e4350859"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/isomer.git", branch: "main"

  depends_on "rust" => :build
  # isomer links cleave as a library, so the cleave CLI is not required -- but
  # the analyzers it embeds still shell out to these tools.
  depends_on "rizin" => :recommended
  # Upstream 7-Zip (`7zz`), not `p7zip`: p7zip's `7z` has no APFS handler, so
  # .dmg contents go unscanned. cleave prefers `7zz` and falls back to `7z`.
  depends_on "sevenzip" => :recommended
  depends_on "upx" => :recommended

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/isomer --version")
  end
end
