class TmpltoolAT11 < Formula
  desc "tmpltool - A fast template renderer supporting many datasources and hundreds of functions."
  homepage "https://github.com/bordeux/tmpltool"
  license "MIT"
  version "1.1.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "2b81c81f43948c47ff950035970caa970bd3603ecbe7f254749c8e7cdbac637d"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "afdea0520adc9455943056ab8d17b807b0ca94b7fd34f33475d2eae875a9a7d7"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "dc07c2e710716676a39223d403aca7f109d9840a65d20c5348539231f9c1a859"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "c513f0e01b15c61b6452be3e5321a00f5c3eb696c739a0127c5b67e27327e325"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
