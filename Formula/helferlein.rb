require_relative "../lib/private_strategy"

class Helferlein < Formula
  desc "Modular macOS admin tools for Munki, network mounts, and user management"
  homepage "https://github.com/finally-studio/helferlein"
  version "1.7.2"
  license "MIT"

  url "https://github.com/finally-studio/helferlein/releases/download/v1.7.2/helferlein.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "b57ccc9f1dc3f103f39ee28fb4f8293bd12ea5fb498ef42f09cd1f5337883070"

  def install
    # Install the main script and all modules to libexec
    libexec.install Dir["*"]

    # Create wrapper script in bin
    (bin/"helferlein").write <<~EOS
      #!/bin/bash
      # Helferlein Homebrew wrapper

      # Get the directory where this wrapper is located
      WRAPPER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
      HELFERLEIN_DIR="$(dirname "$WRAPPER_DIR")/libexec"

      # Source the main helferlein script
      source "$HELFERLEIN_DIR/helferlein.sh"

      # If arguments provided, run them directly
      if [[ $# -gt 0 ]]; then
        "$@"
      else
        # Show help if no arguments
        helferlein help
      fi
    EOS

    chmod 0755, bin/"helferlein"

    # Install shell completions from the already installed libexec directory
    zsh_completion.install libexec/"completions/_helferlein"
  end

  def caveats
    <<~EOS
      Helferlein provides modular macOS admin tools organized as subcommands.

      To activate helferlein, add it to your shell profile:
        echo 'source #{opt_libexec}/helferlein.sh' >> ~/.zshrc

      Then restart your terminal or run:
        source ~/.zshrc

      Configuration:
        Edit #{opt_libexec}/config/config.conf with your settings:
        • SERVIERER_IP: Your server IP address
        • PRODUCTION_MOUNT_PATH: Local mount point for production share
        • MUNKI_REPO_MOUNT_PATH: Local mount point for Munki repository
        • PROTECTED_USER: User to protect from mass logout operations

      Available command categories:
        • Munki Management: munki update, munki repo-clean, etc.
        • Network Mounts: mountshare/unmountshare for SMB shares
        • User Management: user bootout, user list, user apps, etc.
        • Media Tools: media fixtime, media validate, media duration
        • Background Jobs: bgrun for long-running tasks, bgjobs to monitor
        • Shell Utilities: hgrep for history search

      Usage examples:
        helferlein help                    # Show all commands
        munki update                       # Update Munki packages
        mountshare all                     # Mount configured network shares
        user bootout all                   # Boot out users (protects configured user)
        user apps florian                  # List running apps for user florian
        media duration ~/Videos            # Calculate total video duration
        bgrun -l convert.log ffmpeg ...    # Run video conversion in background
        bgjobs                             # List background jobs

      For remote workflows:
        bgrun commands survive SSH disconnections using nohup.
        Perfect for long-running tasks on remote servers.
    EOS
  end

  test do
    # Test that the wrapper script works
    assert_match "Helferlein - macOS Admin Tools", shell_output("#{bin}/helferlein")

    # Test that individual commands are available after sourcing
    system "bash", "-c", "source #{libexec}/helferlein.sh && type munki"
    system "bash", "-c", "source #{libexec}/helferlein.sh && type bgrun"
    system "bash", "-c", "source #{libexec}/helferlein.sh && type mountshare"
    system "bash", "-c", "source #{libexec}/helferlein.sh && type hgrep"
    system "bash", "-c", "source #{libexec}/helferlein.sh && type media"

    # Test configuration file exists
    assert_predicate libexec/"config/config.conf", :exist?

    # Test completion file exists
    assert_predicate zsh_completion/"_helferlein", :exist?
  end
end
