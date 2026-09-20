require_relative "../lib/private_strategy"

class Homesync < Formula
  desc "Minimal NAS synchronization tool for home directory folders"
  homepage "https://github.com/finally-studio/homesync"
  version "1.0.1"
  license "MIT"

  url "https://github.com/finally-studio/homesync/releases/download/v1.0.1/homesync.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "ecf0658bdf16780a383f5c13caada07e9c06f81fd48803a4624fb8bcd5041795"

  depends_on "rsync"

  def install
    bin.install "homesync"
  end

  def caveats
    <<~EOS
      homesync automatically detects NAS mounts and syncs home directory folders.

      Features:
        • Auto-detection of NAS mounts via mount command
        • Profile-based folder selection (basic/full)
        • Push (mirror) and pull (additive) sync modes
        • Built-in exclusions for system files
        • Dry-run support for safe testing

      Usage examples:
        homesync push --dry-run                    # Essential folders only (default)
        homesync push --profile basic              # Library/Preferences + Library/Application Support
        homesync pull --profile full --dry-run     # Desktop + Documents + Downloads + Library
        homesync push --profile full               # Full sync to NAS

      Profiles:
        basic (default): Library/Preferences + Library/Application Support
        full:           Desktop + Documents + Downloads + Library folders

      Sync modes:
        push: Mirrors local folders to NAS (deletes extra files on NAS)
        pull: Adds newer/missing files from NAS to local (no deletions)

      Requirements:
        • macOS with mounted NAS (auto-detected)
        • rsync (provided by this formula or system)
    EOS
  end

  test do
    # Test that the script runs and shows help
    output = shell_output("#{bin}/homesync 2>&1", 1)
    assert_match "Usage:", output
    assert_match "push|pull", output

    # Test profile validation
    output = shell_output("#{bin}/homesync push --profile invalid 2>&1", 1)
    assert_match "Unknown profile", output

    # Test argument parsing
    output = shell_output("#{bin}/homesync invalid 2>&1", 1)
    assert_match "Invalid mode", output
  end
end
