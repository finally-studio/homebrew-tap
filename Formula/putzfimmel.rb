require_relative "../lib/private_strategy"

class Putzfimmel < Formula
  include Language::Python::Virtualenv

  desc "Tidy up project folders: pack, unpack, sweep and convert footage"
  homepage "https://github.com/finally-studio/putzfimmel"
  version "0.7.1"
  license "MIT"

  url "https://github.com/finally-studio/putzfimmel/releases/download/v0.7.1/putzfimmel.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "ffe4a2ef8df54b60572b07e1cec346421edf5505976cdcbc6749fa17524af0a8"

  depends_on "ffmpeg"
  depends_on "gpac" # MP4Box: `inspect` reads the mp4 colr atom with it
  depends_on "mediainfo" # `inspect` dumps the real VUI with it
  depends_on "python@3.13"
  depends_on "zstd"

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "putzfimmel #{version}", shell_output("#{bin}/putzfimmel --version")
    assert_match "fimmel #{version}", shell_output("#{bin}/fimmel --version")
  end
end
