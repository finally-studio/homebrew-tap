require_relative "../lib/private_strategy"

class Transpath < Formula
  include Language::Python::Virtualenv

  desc "Simple file path translator between storage locations"
  homepage "https://github.com/finally-studio/transpath"
  version "1.1.0"
  license "MIT"

  url "https://github.com/finally-studio/transpath/releases/download/v1.1.0/transpath.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "501f05f9c69e9eeac7c6bece401ce22bb58b658f4f1105ed3127503430d473dc"

  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "Translate file paths between storage locations", shell_output("#{bin}/transpath --help")
  end
end
