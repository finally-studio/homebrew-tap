require_relative "../lib/private_strategy"

class Getfinder < Formula
  include Language::Python::Virtualenv

  desc "Get Finder selection and current directory from command line"
  homepage "https://github.com/finally-studio/getfinder"
  version "2025.2.2"
  license "MIT"

  url "https://github.com/finally-studio/getfinder/releases/download/2025.2.2/getfinder.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "d3ce4836f024f538e23719ed350c723a090fd4e4c9bb1f78fe41a7f63d38dde6"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage:", shell_output("#{bin}/getfinder --help")
    assert_match "2025.2", shell_output("#{bin}/getfinder --version")
  end
end
