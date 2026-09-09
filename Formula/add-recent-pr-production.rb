require_relative "../lib/private_strategy"

class AddRecentPrProduction < Formula
  desc "Add Premiere Pro productions to Recent Productions MRU list"
  homepage "https://github.com/finally-studio/add-recent-pr-production"
  version "0.1.0"
  license :cannot_represent

  url "https://github.com/finally-studio/add-recent-pr-production/releases/download/v0.1.0/add-recent-pr-production.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "3cc726a234ebdb064aad0df3cbb8fc97231fa145f6fce53c0b750a5c82959e46"

  def install
    bin.install "add-recent-pr-production"
  end

  test do
    system bin/"add-recent-pr-production", "--help"
  end
end
