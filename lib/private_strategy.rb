require "download_strategy"
require "utils/github"

# Downloads a file from a private GitHub repository.
# Authenticates with HOMEBREW_GITHUB_API_TOKEN.
class GitHubPrivateRepositoryDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    super
    parse_url_pattern
    set_github_token
  end

  def parse_url_pattern
    unless (match = url.match(%r{https://github\.com/([^/]+)/([^/]+)/(\S+)}))
      raise CurlDownloadStrategyError, "Invalid URL pattern for GitHub repository."
    end

    _, @owner, @repo, @filepath = *match
  end

  def download_url
    "https://#{@github_token}@github.com/#{@owner}/#{@repo}/#{@filepath}"
  end

  private

  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url, to: temporary_path, timeout: timeout
  end

  def set_github_token
    @github_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
    if @github_token.blank?
      raise CurlDownloadStrategyError,
            "HOMEBREW_GITHUB_API_TOKEN is required to install from this tap."
    end

    validate_github_repository_access!
  end

  def validate_github_repository_access!
    GitHub::API.open_rest("#{GitHub::API_URL}/repos/#{@owner}/#{@repo}")
  rescue GitHub::API::HTTPNotFoundError
    raise CurlDownloadStrategyError, <<~EOS
      HOMEBREW_GITHUB_API_TOKEN cannot access #{@owner}/#{@repo}.
      The token may lack permission, or you may not have been granted repo access yet.
    EOS
  end
end

# Downloads a release asset from a private GitHub repository.
class GitHubPrivateRepositoryReleaseDownloadStrategy < GitHubPrivateRepositoryDownloadStrategy
  def parse_url_pattern
    url_pattern = %r{https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    unless @url =~ url_pattern
      raise CurlDownloadStrategyError, "Invalid URL pattern for GitHub release."
    end

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  def download_url
    "#{GitHub::API_URL}/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}"
  end

  private

  # The Accept header is required. Without it the API returns JSON metadata
  # rather than the binary, and the sha256 check fails with a confusing mismatch.
  def _fetch(url:, resolved_url:, timeout:)
    curl_download download_url,
                  "--header", "Authorization: Bearer #{@github_token}",
                  "--header", "Accept: application/octet-stream",
                  to:         temporary_path,
                  timeout:    timeout
  end

  def asset_id
    @asset_id ||= begin
      release = GitHub::API.open_rest(
        "#{GitHub::API_URL}/repos/#{@owner}/#{@repo}/releases/tags/#{@tag}",
      )
      asset = release["assets"].find { |a| a["name"] == @filename }
      raise CurlDownloadStrategyError, "Asset #{@filename} not found in #{@tag}." if asset.nil?

      asset["id"]
    end
  end
end
