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
      url "https://github.com/atomdrift-project/scan/releases/download/v2.12.1/atomscan-2.12.1-aarch64-apple-darwin.tar.gz"
      sha256 "48dee4f8cb5a972327fe21cd867ddb721dcf86ef901e06e1edb05be786952690"
    end
    on_intel do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.12.1/atomscan-2.12.1-x86_64-apple-darwin.tar.gz"
      sha256 "9cc3717725a2e83c72c504e6005d77278a7ba3c8b049efce8e35dac67f507aaf"
    end
  end

  # musl, not gnu. The gnu builds are dynamically linked against libc.so.6,
  # libstdc++.so.6, and libgcc_s.so.1, and require symbols up to GLIBC_2.34 --
  # fine on a Homebrew tier 1 host (glibc >= 2.39), broken on RHEL 8 (2.28),
  # Debian 11 and Ubuntu 20.04 (2.31). Homebrew installs its own glibc and gcc
  # on those tier 2 systems, but that is for formulas it builds; a prebuilt
  # binary dropped into the Cellar is still resolved against the host's loader.
  # The musl builds are static-pie with zero NEEDED entries on both
  # architectures, so they have no version floor at all. isomer-action already
  # installs these same musl targets on Linux runners.
  on_linux do
    on_arm do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.12.1/atomscan-2.12.1-aarch64-unknown-linux-musl.tar.gz"
      sha256 "01d7d204fb8ca7ae5738f541c75bf627a02209f9709f1f9be39e15af21bf7a01"
    end
    on_intel do
      url "https://github.com/atomdrift-project/scan/releases/download/v2.12.1/atomscan-2.12.1-x86_64-unknown-linux-musl.tar.gz"
      sha256 "a42bb7ca88157398c78e445c5b2f1812ecc1fba655d6fd6d16480a871e1ac39e"
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
