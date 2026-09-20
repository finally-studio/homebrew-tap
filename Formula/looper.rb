require_relative "../lib/private_strategy"

class Looper < Formula
  desc "Flexible batch file processor with dynamic placeholders for command templates"
  homepage "https://github.com/finally-studio/looper"
  version "1.3.9"
  license "MIT"

  url "https://github.com/finally-studio/looper/releases/download/v1.3.9/looper.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "31436d022fa6e1544f39026257c0819b7935f2794efeecaca117c31717a2d611"

  depends_on "python@3.11"

  def install
    bin.install "bin/looper"
  end

  def caveats
    <<~EOS
      looper is a flexible batch file processor with dynamic placeholders.

      Features:
        • Smart placeholder system for input/output paths
        • Automatic shell function/alias detection - no --shell flag needed
        • Progress tracking for resumable workflows
        • Multi-worker support for parallel processing
        • Regex replacements on output filenames
        • Path translation with transpath integration
        • Process arbitrary strings with --strings mode
        • Extension filtering (case-sensitive or case-insensitive)

      Usage examples:
        looper --ext-in mp4,mxf,mov -- ffmpeg -i {} {outpath}
        looper files.txt --track-progress -- command {} {outpath}
        looper --replace "s/ /_/g" -- command {} {outpath}
        looper --name-pattern "{stem}_converted" --ext-out mkv -- ffmpeg -i {} {outpath}
        looper --shell -- media fixtime {}
        looper --transpath files.txt -- command {}
        looper --strings names.txt -- touch {}
        looper --quiet -- command {}  # suppress command echo

      Available placeholders:
        {}         - Full input file path
        {basename} - Filename with extension
        {stem}     - Filename without extension
        {ext-in}   - Input file extension
        {ext-out}  - Output file extension
        {outpath}  - Full output path
    EOS
  end

  test do
    # Test that the script runs and shows help
    assert_match "looper – batch process files", shell_output("#{bin}/looper --help")

    # Test basic functionality with dry-run
    (testpath/"test.txt").write("#{testpath}/sample.mp4\n")
    (testpath/"sample.mp4").write("")

    output = shell_output("#{bin}/looper #{testpath}/test.txt --dry-run -- echo 'Processing: {}'")
    assert_match "sample.mp4", output
    assert_match "Summary:", output

    # Test placeholder replacement
    output = shell_output("#{bin}/looper #{testpath}/test.txt --dry-run -- echo 'Input: {basename} Output: {outpath}'")
    assert_match "Input: sample.mp4", output
    assert_match "Output:", output

    # Test --strings mode
    (testpath/"strings.txt").write("test1\ntest2\n")
    output = shell_output("#{bin}/looper --strings #{testpath}/strings.txt --dry-run -- echo '{}'")
    assert_match "test1", output
    assert_match "test2", output
  end
end
