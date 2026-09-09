require_relative "../lib/private_strategy"

class Faulancer < Formula
  desc "Notion databases to Premiere Pro timelines (JSX generation)"
  homepage "https://github.com/finally-studio/faulancer"
  version "0.1.0"
  license :cannot_represent

  url "https://github.com/finally-studio/faulancer/releases/download/v0.1.0/faulancer.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "697d3ebd85df6bef952c7557f512a7d26d98c872d97192d2f4565e661a0316fc"

  depends_on "python@3.13"
  depends_on :macos

  def install
    python3 = Formula["python@3.13"].opt_bin/"python3.13"
    system python3, "-m", "venv", libexec/"venv"
    venv_pip = libexec/"venv/bin/pip"
    system venv_pip, "install", "--quiet", "--upgrade", "pip"
    system venv_pip, "install", "--quiet", "-r", "requirements.txt"

    libexec.install Dir["*"]

    (bin/"faulancer").write <<~SH
      #!/bin/bash
      exec "#{libexec}/venv/bin/python" "#{libexec}/faulancer.py" "$@"
    SH
    chmod 0755, bin/"faulancer"
  end

  test do
    assert_predicate bin/"faulancer", :executable?
  end
end
