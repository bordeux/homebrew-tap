class TmpltoolAT12 < Formula
  desc "tmpltool - A fast template renderer supporting many datasources and hundreds of functions."
  homepage "https://github.com/bordeux/tmpltool"
  license "MIT"
  version "1.2.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "dc780e1662ab31234ce6af05292789e6e53505a42ffe0ab79dc2c6ae4e3a5a26"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "a59a4273355d862ff4bd515b030a6c8406f46dfd0651618921d8476aed69eb24"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "58c9390504050e90977fa08d360efd52d3f719a91b8c2f0e9c499e2ed90f050d"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "323f1c7dee7dddd5e551fbc35315340ccecdda7fc2522a8f3aed4dea0e82645c"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
