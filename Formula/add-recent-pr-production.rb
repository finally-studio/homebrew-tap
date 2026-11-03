require_relative "../lib/private_strategy"

class AddRecentPrProduction < Formula
  desc "Add Premiere Pro productions to Recent Productions MRU list"
  homepage "https://github.com/finally-studio/add-recent-pr-production"
  version "0.1.2"
  license :cannot_represent

  url "https://github.com/finally-studio/add-recent-pr-production/releases/download/v0.1.2/add-recent-pr-production.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "fe1a507c4c24f6801199bcadcec583b1739e8c5b53f0f60c43d524bbde3a44e6"

  def install
    bin.install "add-recent-pr-production"
  end

  test do
    system bin/"add-recent-pr-production", "--help"
  end
end
