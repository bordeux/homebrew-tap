class TmpltoolAT14 < Formula
  desc "Fast template renderer supporting many datasources and hundreds of functions"
  homepage "https://github.com/bordeux/tmpltool"
  version "1.4.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "847d8e76acdb68045d086324e6381bf73005d3dadba9464746ce7ad56890ca8e"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "68431c196a631e163d9efda958e966a351e422f58c233dfb85e66f91ad11ee08"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "ac621e97ad293d5659097b8bf3da746e7464887b106d84d929ccd7351bb26489"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "26dc3fe69208b52c145b03d3650393162b5f1cf1a339b5047d09bede532bdaaa"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
