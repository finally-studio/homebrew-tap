require_relative "../lib/private_strategy"

class AddRecentPrProduction < Formula
  desc "Add Premiere Pro productions to Recent Productions MRU list"
  homepage "https://github.com/finally-studio/add-recent-pr-production"
  version "0.1.1"
  license :cannot_represent

  url "https://github.com/finally-studio/add-recent-pr-production/releases/download/v0.1.1/add-recent-pr-production.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "d9e99ffa9bb313b7aa841ea00fa2b23aac414e705c637d54bacdc3332a9097e8"

  def install
    bin.install "add-recent-pr-production"
  end

  test do
    system bin/"add-recent-pr-production", "--help"
  end
end
