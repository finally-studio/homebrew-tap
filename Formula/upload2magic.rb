require_relative "../lib/private_strategy"

class Upload2magic < Formula
  desc "Upload files to transfer.finally-studio.com"
  homepage "https://github.com/finally-studio/upload2magic"
  version "1.1.2"
  license "MIT"

  url "https://github.com/finally-studio/upload2magic/releases/download/v1.1.2/upload2magic.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "f18cb2e31cd3b094021aa929128c837d07e2643fc627ee91a08ce1624198a94e"

  depends_on "python@3.11"
  depends_on "p7zip"

  def install
    libexec.install "upload2magic.py"
    system "pip3", "install", "--target=#{libexec}/lib", "urllib3<2", "requests"

    (bin/"upload2magic").write <<~EOS
      #!/bin/bash
      export PYTHONPATH="#{libexec}/lib:$PYTHONPATH"
      exec python3 "#{libexec}/upload2magic.py" "$@"
    EOS

    chmod 0755, bin/"upload2magic"
  end

  def caveats
    <<~EOS
      Ensure SSH key exists at:
      /Users/Shared/finally-studio/.ssh/id_rsa_transfer
    EOS
  end

  test do
    system "#{bin}/upload2magic", "--help"
  end
end
