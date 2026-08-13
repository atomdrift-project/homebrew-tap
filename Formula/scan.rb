class Scan < Formula
  desc "Context-free malware detection using ML and cleave static analysis"
  homepage "https://github.com/atomdrift-project/scan"
  license "Apache-2.0"

  head do
    url "https://github.com/atomdrift-project/scan.git", branch: "main"

    depends_on "rust" => :build
  end

  # cleave is linked into atomscan as a library crate, so the cleave CLI is not
  # required -- but the analyzers it embeds still shell out to these tools.
  depends_on "rizin" => :recommended
  # Upstream 7-Zip (`7zz`), not `p7zip`: p7zip's `7z` has no APFS handler, so
  # .dmg contents go unscanned. cleave prefers `7zz` and falls back to `7z`.
  depends_on "sevenzip" => :recommended
  depends_on "upx" => :recommended

  on_macos do
    on_arm do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.6.0/atomscan-2.6.0-aarch64-apple-darwin.tar.gz"
      sha256 "5bacf5f327767b9a484db0f4b6ad4299cbe9d52d7e4bf3e0dc4fe1e06cb2afa4"
    end
    on_intel do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.6.0/atomscan-2.6.0-x86_64-apple-darwin.tar.gz"
      sha256 "c8a82af5e74799082cba461a47743afee384fc90741f2eeee55ac824bff31901"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.6.0/atomscan-2.6.0-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "9e2705c55b96cb0656628965fd02e3b7e1ccee7c5cfe62e1bd31123ec436fe1f"
    end
    on_intel do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.6.0/atomscan-2.6.0-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "05386d112c0f35dc56f663cf413488fa7789ad245d0d8f20b74839dec090d7e4"
    end
  end

  def install
    if build.head?
      system "cargo", "install", *std_cargo_args
    else
      bin.install "atomscan"
    end
  end

  test do
    assert_match "atomscan", shell_output("#{bin}/atomscan --help")
    assert_match version.to_s, shell_output("#{bin}/atomscan --version")

    # Scan a real file rather than stopping at --help. yara-x compiles rules to
    # WebAssembly and runs them through wasmtime/cranelift, so this is the first
    # thing to touch the JIT -- and on macOS a hardened-runtime build with
    # insufficient entitlements is SIGKILLed here ("Code Signature Invalid")
    # while --help and --version still pass. Keep this test executing a scan.
    (testpath/"sample.sh").write <<~EOS
      #!/bin/sh
      echo hello
    EOS
    assert_match "1 files scanned", shell_output("#{bin}/atomscan sample.sh 2>&1")
  end
end
