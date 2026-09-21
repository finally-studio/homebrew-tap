require_relative "../lib/private_strategy"

class Findduplicates < Formula
  include Language::Python::Virtualenv

  desc "Fast duplicate file and folder finder with combinable matching criteria"
  homepage "https://github.com/finally-studio/findduplicates"
  version "1.1.2"
  license "MIT"

  url "https://github.com/finally-studio/findduplicates/releases/download/v1.1.2/findduplicates.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "afad6e4e67b7607416a2a04a9251efcaec74c7c8f36a0a7f5d66c89bc8d2d4ce"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage:", shell_output("#{bin}/findduplicates --help")
    assert_match "Find duplicate files", shell_output("#{bin}/findduplicates files --help")
  end
end
