class Tmpltool < Formula
  desc "Fast template renderer supporting many datasources and hundreds of functions"
  homepage "https://github.com/bordeux/tmpltool"
  version "1.5.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "cbf60dd870efb8bf93ad20814b6d0d0a9c4f901077308c71ccccfa41e6abdee3"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "26b6cde2d901b6f807c809f92c93dee62f5132a2e1a555eeba0baf1bbfddd75a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "f69483167dd09ccfab012e1f24e95a2bf26c11ee9b726787aa083f95d7643e6d"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "4ad16794199d593199b11d14814b698d5ea375a4a80413c8fc863a985122c7f8"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
