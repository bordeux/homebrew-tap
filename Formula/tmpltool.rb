class Tmpltool < Formula
  desc "Fast template renderer supporting many datasources and hundreds of functions"
  homepage "https://github.com/bordeux/tmpltool"
  version "1.4.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "994dc3f7e4c7ab7875a74a4612e4a9762bab4fb0cbb4f681524d79e872b8ab19"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "f8c0acfe8000bb3dbc442c45c3cac52f6987d8e479de4b22ebcc5121493fafbe"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "852d1d8ed9b32196700912f78f369b90215f002a0743f03d5f1b3e8f2682d0a1"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "d623e785a4c0579a3de7a636a2858402018247b329196668c9f1080a6c7e07ea"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")
  end
end
