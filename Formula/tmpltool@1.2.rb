class TmpltoolAT12 < Formula
  desc "tmpltool - A fast template renderer supporting many datasources and hundreds of functions."
  homepage "https://github.com/bordeux/tmpltool"
  license "MIT"
  version "1.2.4"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "e6a053c6b764f47cd75e61f20f4797f5e24138079437b14b80dabbcf476440a0"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "da830d8d3d6685b3f0cb1b44f9867ecd37aca8a006612262347f8446bb123e86"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "0033cb28467e00129feab554493d06794e1d70372a12b170e23f23156e6fdbed"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "db3338ecf91dc3f6397f97f045c03eaab8cc622bd5bdc13239ea095376ad084d"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
