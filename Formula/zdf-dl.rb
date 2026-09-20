require_relative "../lib/private_strategy"

class ZdfDl < Formula
  include Language::Python::Virtualenv

  desc "Programmatic downloader for ZDF Upload Portal share links"
  homepage "https://github.com/finally-studio/zdf-dl"
  version "0.1.3"
  license "MIT"

  url "https://github.com/finally-studio/zdf-dl/releases/download/v0.1.3/zdf-dl.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "d5bf2ecdc2b3cb98117a29fd9a2ded7b1f32858e8deb315fe3eaaa812f092253"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "ZDF Upload Portal", shell_output("#{bin}/zdf-dl --help")
  end
end
