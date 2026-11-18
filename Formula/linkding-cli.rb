require_relative "../lib/private_strategy"

class LinkdingCli < Formula
  include Language::Python::Virtualenv

  desc "macOS client for the linkding symlink management server"
  homepage "https://github.com/finally-studio/linkding-cli"
  version "1.0.1"

  url "https://github.com/finally-studio/linkding-cli/releases/download/v1.0.1/linkding-cli.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "d29538d99110a6825c6799aa3f048a34fd1171cce0101dc8bbe1066dd79727bb"

  depends_on "finally-studio/tap/transpath"
  depends_on "python@3.11"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/linkding-cli --version")
  end
end
