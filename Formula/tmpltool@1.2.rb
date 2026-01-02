class TmpltoolAT12 < Formula
  desc "tmpltool - A fast template renderer supporting many datasources and hundreds of functions."
  homepage "https://github.com/bordeux/tmpltool"
  license "MIT"
  version "1.2.3"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "feba3c3d104918378758ead8ca6c3220a7661e3486420d55182ba879b2649f98"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "f79d9e3ab0e57d2b643b80710bc3cddecba4dc876dd339333703c077f6c45dc0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "66dec14ffd056af3223b493780863d0419dfb51b9139b705abc08418d7e64e0c"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "48be604206eb76d4599c93725ed6a09bba4486a9cfb1e13d775ec88d48b953f1"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
