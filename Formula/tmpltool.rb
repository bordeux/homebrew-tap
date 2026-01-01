class Tmpltool < Formula
  desc "Fast CLI template rendering tool using MiniJinja templates"
  homepage "https://github.com/bordeux/tmpltool"
  license "MIT"
  version "1.1.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-aarch64.tar.gz"
      sha256 "PLACEHOLDER_MACOS_AARCH64_SHA256"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-macos-x86_64.tar.gz"
      sha256 "PLACEHOLDER_MACOS_X86_64_SHA256"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-aarch64.tar.gz"
      sha256 "PLACEHOLDER_LINUX_AARCH64_SHA256"
    else
      url "https://github.com/bordeux/tmpltool/releases/download/v#{version}/tmpltool-linux-x86_64.tar.gz"
      sha256 "PLACEHOLDER_LINUX_X86_64_SHA256"
    end
  end

  def install
    bin.install "tmpltool"
  end

  test do
    # Test version output
    assert_match version.to_s, shell_output("#{bin}/tmpltool --version")

    # Test basic template rendering
    (testpath/"test.tmpl").write("Hello {{ get_env(name=\"USER\", default=\"World\") }}!")
    output = shell_output("#{bin}/tmpltool #{testpath}/test.tmpl")
    assert_match "Hello", output
  end
end
