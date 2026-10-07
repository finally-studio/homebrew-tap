require_relative "../lib/private_strategy"

class Low2high < Formula
  desc "Convert low-resolution images to high-resolution using Getty Images and other stock photo services"
  homepage "https://github.com/finally-studio/low2high"
  version "2.4.0"
  license "MIT"

  url "https://github.com/finally-studio/low2high/releases/download/v2.4.0/low2high.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "bb5e397e2e6945d38fe3c0959aa3d956d7c3e26caffd08fff80c7595aaadb49d"

  depends_on "python@3.11"

  def install
    system "python3.11", "-m", "venv", libexec
    system "#{libexec}/bin/pip", "install", "--upgrade", "pip"
    system "#{libexec}/bin/pip", "install", buildpath
    bin.install_symlink libexec/"bin/low2high"
  end

  test do
    assert_match "Convert low-resolution images to high-resolution", shell_output("#{bin}/low2high --help")
    assert_match "getty", shell_output("#{bin}/low2high --help")
  end
end
