require_relative "../lib/private_strategy"

class LinkdingCli < Formula
  include Language::Python::Virtualenv

  desc "macOS client for the linkding symlink management server"
  homepage "https://github.com/finally-studio/linkding-cli"
  version "1.0.2"

  url "https://github.com/finally-studio/linkding-cli/releases/download/v1.0.2/linkding-cli.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "de51ee2f535c58879a0556a1906f8191777a8165d07ee8112d9b9a5e75e81b44"

  depends_on "finally-studio/tap/transpath"
  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/linkding-cli --version")
  end
end
