require_relative "../lib/private_strategy"

class FrameioCli < Formula
  desc "CLI tool for uploading files to Frame.io"
  homepage "https://github.com/finally-studio/frameio-cli"
  version "0.4.12"
  license "MIT"

  url "https://github.com/finally-studio/frameio-cli/releases/download/v0.4.12/frameio-cli.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "c6d6cc32bf8488e0c4f8e5dff6bf3f8a2375fe112f94bcb9861e4e849e15c10f"

  depends_on "python@3.13"

  def install
    python3 = Formula["python@3.13"].opt_bin/"python3.13"
    system python3, "-m", "venv", libexec
    system libexec/"bin/pip", "install", "."

    # Wrapper that suppresses resource_tracker semaphore warnings in child processes
    (bin/"frameio").write <<~EOS
      #!/bin/sh
      export PYTHONWARNINGS="ignore::UserWarning:multiprocessing.resource_tracker${PYTHONWARNINGS:+,$PYTHONWARNINGS}"
      exec "#{libexec}/bin/frameio" "$@"
    EOS
    chmod 0755, bin/"frameio"
  end

  test do
    assert_match "Frame.io CLI", shell_output("#{bin}/frameio --help")
  end
end
