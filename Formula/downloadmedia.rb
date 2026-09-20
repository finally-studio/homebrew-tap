require_relative "../lib/private_strategy"

class Downloadmedia < Formula
  desc "Minimal CLI tool for downloading videos with yt-dlp"
  homepage "https://github.com/finally-studio/downloadmedia"
  version "1.0.1"
  license "MIT"

  url "https://github.com/finally-studio/downloadmedia/releases/download/v1.0.1/downloadmedia.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "95368c4562fcf120daac19b1813a27d53ba9da7363205f19b550c9789773691d"

  depends_on "python@3.13"
  depends_on "yt-dlp"
  depends_on "ffmpeg"

  def install
    system "python3.13", "-m", "venv", libexec
    system "#{libexec}/bin/pip", "install", "--upgrade", "pip"
    system "#{libexec}/bin/pip", "install", buildpath
    bin.install_symlink libexec/"bin/downloadmedia"
  end

  test do
    assert_match "Download videos from YouTube", shell_output("#{bin}/downloadmedia --help")
  end
end
