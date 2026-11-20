require_relative "../lib/private_strategy"

class Putzfimmel < Formula
  include Language::Python::Virtualenv

  desc "Tidy up project folders: pack, unpack, sweep and convert footage"
  homepage "https://github.com/finally-studio/putzfimmel"
  version "0.4.3"
  license "MIT"

  url "https://github.com/finally-studio/putzfimmel/releases/download/v0.4.3/putzfimmel.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "0bb6a6cc6b69e8aa4cd350f52ade558333fe2a40a7a78cad86b741351005ef85"

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
