class Tmpltool < Formula
  desc "tmpltool - A fast template renderer supporting many datasources and hundreds of functions."
  homepage "https://github.com/bordeux/tmpltool"
  license "MIT"
  version "1.2.5"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "8a8456cf0a0ae0dfbf2914f113f4d6b96e08e6c9010de867a8190928d8422ab6"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "8b5a926b685825f83763b54be1f2f2b327979d8d723766700786ca7320208e3d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "aa0e300cf899c6ded5f7ce2209d183aa0c784a3fe3dcba34066ec41843942846"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "e4a0354c0045740ab719f557a398e91a12b99bd74acd0827a37b73f866ff8241"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
