require_relative "../lib/private_strategy"

class Vqc < Formula
  desc "Video Quality Control for post-production cleanfeeds"
  homepage "https://github.com/finally-studio/vqc"
  version "0.4.0"
  license "MIT"

  url "https://github.com/finally-studio/vqc/releases/download/v0.4.0/vqc.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "35db75be93e0386509aa472a4480909549830b3575166704f4e0165e358aed10"

  depends_on "python@3.13"

  def install
    python3 = Formula["python@3.13"].opt_bin/"python3.13"
    system python3, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "."
    bin.install_symlink libexec/"bin/vqc"
  end

  test do
    assert_match "Video Quality Control", shell_output("#{bin}/vqc --help")
  end
end
