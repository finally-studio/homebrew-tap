require_relative "../lib/private_strategy"

class Convert2magic < Formula
  desc "Modern Python video conversion tool with professional FFmpeg presets"
  homepage "https://github.com/finally-studio/convert2magic"
  version "1.3.1"
  license "MIT"

  url "https://github.com/finally-studio/convert2magic/releases/download/v1.3.1/convert2magic.tar.gz",
      using: GitHubPrivateRepositoryReleaseDownloadStrategy
  sha256 "f394297ba134372c5a58c6abf71334a7f480920f49a56a3240393d63055faf5d"

  depends_on "python@3.11"
  depends_on "ffmpeg"

  def install
    python3 = Formula["python@3.11"].opt_bin/"python3.11"

    # Install source files to libexec directory
    libexec.install Dir["src/*"]

    # Install Python dependencies using the pinned interpreter's pip
    system python3, "-m", "pip", "install", "--target=#{libexec}/lib", "click>=8.0.0", "PyYAML>=6.0"

    # Create a proper wrapper script that works with Homebrew layout
    (bin/"convert2magic").write <<~EOS
      #!#{python3}
      import sys
      import os
      from pathlib import Path

      # Add Homebrew-installed dependencies to Python path
      libexec_lib = "#{libexec}/lib"
      libexec_root = "#{libexec}"

      sys.path.insert(0, libexec_lib)
      sys.path.insert(0, libexec_root)

      # Change to libexec directory for relative imports
      os.chdir(libexec_root)

      if __name__ == '__main__':
          try:
              import convert2magic
              convert2magic.main()
          except ImportError as e:
              print(f"Error: Could not import convert2magic module: {e}", file=sys.stderr)
              sys.exit(1)
          except Exception as e:
              print(f"Error: {e}", file=sys.stderr)
              sys.exit(1)
    EOS

    chmod 0755, bin/"convert2magic"
  end

  def caveats
    <<~EOS
      convert2magic requires FFmpeg to be installed and available in PATH.

      Usage examples:
        convert2magic -p h264 input.mov
        convert2magic -p h264_proxy --ffmpeg-opts "-ss 00:01:30 -t 30" input.mov
        convert2magic -p h264 --dry-run input.mov
    EOS
  end

  test do
    system "#{bin}/convert2magic", "--help"
    system "ffmpeg", "-version"
  end
end
