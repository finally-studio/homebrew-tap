require_relative "../lib/private_strategy"

class Splitpdf < Formula
  desc "Multi-format PDF splitter with After Effects compatibility"
  homepage "https://github.com/finally-studio/splitpdf"
  version "1.4.1"
  license "MIT"

  url "https://github.com/finally-studio/splitpdf/releases/download/v1.4.1/splitpdf.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "bdf0fb33d886310d78bf0ae2dcf21c0ec6ca5f7f02be4aeeae637fff003af587"

  depends_on "qpdf"         # for lossless PDF optimization and page count
  depends_on "poppler"      # for pdfseparate, pdftops, pdftoppm
  depends_on "parallel"

  def install
    bin.install "splitpdf"
  end

  test do
    system "#{bin}/splitpdf", "--help"
  end
end
