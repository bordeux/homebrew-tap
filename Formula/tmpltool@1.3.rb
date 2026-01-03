class TmpltoolAT13 < Formula
  desc "Fast template renderer supporting many datasources and hundreds of functions"
  homepage "https://github.com/bordeux/tmpltool"
  version "1.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "dcf75f7b32882977abf1409d57c63ddc8897d8010c510cc3dc4311d10cd18ff9"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "607773f4ff3723e6f49feea5dfe128eef8acd475185002ce65ef7af35c6c3e14"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "3479ea129eb5d1b22cdc1e4d8345b75d20b9a8cc17dac0e7ed7c06ecc762ae85"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "08c58b1ffba2c64318e509b0141cff831267e126b297c056b038df63bd8eda70"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
