require_relative "../lib/private_strategy"

class Vqc < Formula
  desc "Video Quality Control for post-production cleanfeeds"
  homepage "https://github.com/finally-studio/vqc"
  version "0.3.2"
  license "MIT"

  url "https://github.com/finally-studio/vqc/releases/download/v0.3.2/vqc.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "a7443039b78d607892d7149964b3130836bc90bf6999ce0a46df4617b40c8668"

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
