require_relative "../lib/private_strategy"

class Transpath < Formula
  include Language::Python::Virtualenv

  desc "Simple file path translator between storage locations"
  homepage "https://github.com/finally-studio/transpath"
  version "1.0.3"
  license "MIT"

  url "https://github.com/finally-studio/transpath/releases/download/v1.0.3/transpath.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "33eb02c0d717e427f2213c083733315acb7bf06459acb0d87fadf7019a64bd4d"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "Translate file paths between storage locations", shell_output("#{bin}/transpath --help")
  end
end
