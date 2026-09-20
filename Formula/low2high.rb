require_relative "../lib/private_strategy"

class Low2high < Formula
  include Language::Python::Virtualenv

  desc "Convert low-resolution images to high-resolution using Getty Images and other stock photo services"
  homepage "https://github.com/finally-studio/low2high"
  version "2.3.1"
  license "MIT"

  url "https://github.com/finally-studio/low2high/releases/download/v2.3.1/low2high.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "3b9785f10cb47a57ce7cabae70886dd384a9f7da9835212b10e5c3abb32f9b15"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "Convert low-resolution images to high-resolution", shell_output("#{bin}/low2high --help")
    assert_match "getty", shell_output("#{bin}/low2high --help")
  end
end
