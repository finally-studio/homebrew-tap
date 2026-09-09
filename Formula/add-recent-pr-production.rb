require_relative "../lib/private_strategy"

class AddRecentPrProduction < Formula
  desc "Add Premiere Pro productions to Recent Productions MRU list"
  homepage "https://github.com/finally-studio/add-recent-pr-production"
  version "0.1.0"
  license :cannot_represent

  url "https://github.com/finally-studio/homebrew-tap/releases/download/add-recent-pr-production-v0.1.0/add-recent-pr-production-v0.1.0.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "b07d9ab5d2b731d403ff39dbef671c0eb4826da0c5f594f3830b507e0a55c202"

  def install
    bin.install "add-recent-pr-production"
  end

  test do
    system bin/"add-recent-pr-production", "--help"
  end
end
