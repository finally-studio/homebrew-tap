require_relative "../lib/private_strategy"

class Faulancer < Formula
  desc "Notion databases to Premiere Pro timelines (JSX generation)"
  homepage "https://github.com/finally-studio/faulancer"
  version "0.1.1"
  license :cannot_represent

  url "https://github.com/finally-studio/faulancer/releases/download/v0.1.1/faulancer.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "6b5bca47c1e66ac5f6d6190ad34d33f856b50078fc9a2c2e49e60c22c005c609"

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
      export FAULANCER_HOME="${FAULANCER_HOME:-$HOME/Library/Application Support/Faulancer}"
      cd "#{libexec}" && "#{libexec}/venv/bin/python" -m src.setup
      exec "#{libexec}/venv/bin/python" "#{libexec}/faulancer.py" "$@"
    SH
    chmod 0755, bin/"faulancer"
  end

  test do
    assert_predicate bin/"faulancer", :executable?
  end
end
