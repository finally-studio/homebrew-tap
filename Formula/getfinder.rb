require_relative "../lib/private_strategy"

class Getfinder < Formula
  include Language::Python::Virtualenv

  desc "Get Finder selection and current directory from command line"
  homepage "https://github.com/finally-studio/getfinder"
  version "2025.2.1"
  license "MIT"

  url "https://github.com/finally-studio/getfinder/releases/download/2025.2.1/getfinder.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "fbd3ade57b626d7cb99ec85b33f961c195bc4bd33cec8d31b8ff82e630d14e85"

  depends_on "python@3.13"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "usage:", shell_output("#{bin}/getfinder --help")
    assert_match "2025.2", shell_output("#{bin}/getfinder --version")
  end
end
