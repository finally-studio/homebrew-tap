require_relative "../lib/private_strategy"

class AddRecentPrProduction < Formula
  desc "Add Premiere Pro productions to Recent Productions MRU list"
  homepage "https://github.com/finally-studio/add-recent-pr-production"
  version "0.1.3"
  license :cannot_represent

  url "https://github.com/finally-studio/add-recent-pr-production/releases/download/v0.1.3/add-recent-pr-production.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "0dcbea2f0ec13e0cd1740f7ab153c09a1ffd5b29a962d417735fe183bbc1207b"

  def install
    bin.install "add-recent-pr-production"
  end

  test do
    system bin/"add-recent-pr-production", "--help"
  end
end
