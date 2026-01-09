class Tmpltool < Formula
  desc "Fast template renderer supporting many datasources and hundreds of functions"
  homepage "https://github.com/bordeux/tmpltool"
  version "1.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "2c5ef0ee0223616d7e7a03c1693dddc95968646c18f80dd7e8d05d5041fa97c2"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "1df648290b47ef476fa075070aa2befb09ff8ebd652432896bdf7c59f0da094b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "adb6fc3bf476aa795aaec0affa169c00886e855ea713eab3bad55ba03afd5763"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "9b9c1f61b83908a062503bf7209da92342fe0a267989834e9df8ec172146d365"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
