require_relative "../lib/private_strategy"

class Putzfimmel < Formula
  include Language::Python::Virtualenv

  desc "Tidy up project folders: pack, unpack, sweep and convert footage"
  homepage "https://github.com/finally-studio/putzfimmel"
  version "0.1.2"
  license "MIT"

  url "https://github.com/finally-studio/putzfimmel/releases/download/v0.1.2/putzfimmel.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "b7738e7a1d7920f8dbe8f3244086eceeaa7b73ed427bd07fbb3feaa9ccf4ff39"

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
