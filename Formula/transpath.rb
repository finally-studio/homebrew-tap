require_relative "../lib/private_strategy"

class Transpath < Formula
  include Language::Python::Virtualenv

  desc "Simple file path translator between storage locations"
  homepage "https://github.com/finally-studio/transpath"
  version "1.1.1"
  license "MIT"

  url "https://github.com/finally-studio/transpath/releases/download/v1.1.1/transpath.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "d5f74620e2fab2d02c7d26caca1e7236b2b6711d308019958df89e4933d282a2"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "Translate file paths between storage locations", shell_output("#{bin}/transpath --help")
  end
end
