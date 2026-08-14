class Hood < Formula
  desc "Scan HTTP(S) payloads before they reach package managers and installers"
  homepage "https://github.com/atomdrift-project/hood"

  url "https://github.com/atomdrift-project/hood.git",
      tag:      "v0.1.0",
      revision: "1b63aeb738144de7c97e991d7d19b1e0e3dacb12"
  license "Apache-2.0"
  head "https://github.com/atomdrift-project/hood.git", branch: "main"

  depends_on "rust" => :build
  # hood links atomdrift-scan as a library, so the atomscan CLI is not required
  # -- but the analyzers it embeds still shell out to these tools.
  depends_on "rizin" => :recommended
  # Upstream 7-Zip (`7zz`), not `p7zip`: p7zip's `7z` has no APFS handler, so
  # .dmg contents go unscanned. cleave prefers `7zz` and falls back to `7z`.
  depends_on "sevenzip" => :recommended
  depends_on "upx" => :recommended

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    assert_match "hood", shell_output("#{bin}/hood --help")
  end
end
