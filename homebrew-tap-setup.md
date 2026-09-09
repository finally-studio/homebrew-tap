# Setup: `finally-studio/homebrew-tap`

Instructions for setting up a private Homebrew tap that distributes prebuilt CLI
binaries to clients, without granting them access to the tool source repos.

## Naming

| Thing | Value |
|---|---|
| GitHub org | `finally-studio` |
| GitHub repo | `homebrew-tap` |
| Local working directory | `homebrew-tap-new` |
| Tap name for `brew tap` | `finally-studio/tap` (Homebrew strips the `homebrew-` prefix) |

Note: an older tap exists elsewhere. Its formulae will be migrated into this repo
later — do not attempt to import or reference it during this setup.

## Architecture

```
  tool-a, tool-b, tool-c        private, clients have NO access
            |
            |  CI, authenticated with TAP_TOKEN
            |  -> uploads release asset + bumps formula
            v
  finally-studio/homebrew-tap   private, clients have READ
            ^
            |  client's own GitHub token
            |  -> git fetch (tap) + release asset download (binary)
            |
      client machine
```

Release assets live on the **tap** repo, not on the tool repos. This is what keeps
the source closed while still letting clients install. Clients receive exactly one
GitHub grant.

Three credentials, three distinct jobs:

- **`TAP_TOKEN`** — ours. Fine-grained PAT or GitHub App installation token,
  `Contents: Read and write` on `homebrew-tap` only. Stored as an org-level Actions
  secret. Never leaves the org.
- **Client token** — the client's own. `Contents: Read` on `homebrew-tap` only.
  Serves double duty: git-over-HTTPS auth for the tap clone, and Bearer auth for the
  release-asset API call.
- **Tool repos** — no client credential exists at all.

---

# Part A — GitHub org configuration

Mostly one-time. Steps marked *(web UI)* have no reliable `gh` equivalent.

### A1. Create the tap repo

```bash
gh repo create finally-studio/homebrew-tap --private \
  --description "Private Homebrew tap for Finally Studio client tooling"
```

### A2. Create the `clients` team

```bash
gh api -X POST /orgs/finally-studio/teams \
  -f name=clients \
  -f description="Read-only access to homebrew-tap for client deployments" \
  -f privacy=secret

gh api -X PUT /orgs/finally-studio/teams/clients/repos/finally-studio/homebrew-tap \
  -f permission=pull
```

`permission=pull` is read-only. Do not grant `push`.

### A3. Allow fine-grained PATs *(web UI)*

Org settings → Third-party Access → Personal access tokens → **Fine-grained personal
access tokens**. Set to **"Allow access via fine-grained personal access tokens"**,
and either enable *"Do not require administrator approval"* or commit to approving
each client's token request.

This step is easy to skip and produces a confusing failure: a client's token that
looks correctly scoped will silently return 404 on the private repo, indistinguishable
from a permissions typo. Verify this setting before onboarding anyone.

### A4. Create and store `TAP_TOKEN`

Create a fine-grained PAT *(web UI: Settings → Developer settings)*:

- Resource owner: `finally-studio`
- Repository access: **only** `finally-studio/homebrew-tap`
- Permissions: `Contents: Read and write`

Store it as an org secret so every tool repo can use it:

```bash
gh secret set TAP_TOKEN --org finally-studio --visibility all
```

Prefer a GitHub App installation token if you want rotation handled automatically —
fine-grained PATs cap at 366 days and will expire mid-project otherwise.

### A5. Confirm tool repos are private with no client access

```bash
gh repo list finally-studio --json name,visibility --limit 100
```

Any tool repo showing `PUBLIC` needs review. No client should appear as a
collaborator on any tool repo.

---

# Part B — Scaffold the tap repository

Work in `homebrew-tap-new/`.

### B1. Layout

```
homebrew-tap-new/
├── Formula/
│   └── example-tool.rb
├── lib/
│   └── private_strategy.rb
├── .github/workflows/
│   └── smoke-test.yml
└── README.md
```

### B2. `lib/private_strategy.rb`

**This is the fragile part of the whole setup.** Homebrew removed
`GitHubPrivateRepositoryReleaseDownloadStrategy` from core in 2.x, so it has to be
vendored here. It touches Homebrew private API and has broken across brew releases
before — most recently when `GitHub.open_api` was disabled in favour of
`GitHub::API.open_rest`, and when `_fetch` gained a `timeout:` keyword.

Write the file below, then **verify it against the installed brew** before trusting it:

```bash
grep -n "def _fetch" $(brew --repo)/Library/Homebrew/download_strategy.rb
grep -rn "def open_rest" $(brew --repo)/Library/Homebrew/utils/github/api.rb
```

If the signatures differ from what's used here, fix this file to match.

```ruby
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
```

### B3. `Formula/example-tool.rb`

Template. Note the `require_relative`, the per-architecture URLs pointing at the
**tap** repo's releases, and the absence of a `head` stanza — a `head` pointing at a
private tool repo would fail for every client.

```ruby
require_relative "../lib/private_strategy"

class ExampleTool < Formula
  desc "Example Finally Studio client tool"
  homepage "https://finally.studio"
  version "0.1.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/finally-studio/homebrew-tap/releases/download/example-tool-v0.1.0/example-tool_darwin_arm64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "REPLACE_ME"
    end
    on_intel do
      url "https://github.com/finally-studio/homebrew-tap/releases/download/example-tool-v0.1.0/example-tool_darwin_amd64.tar.gz",
          using: GitHubPrivateRepositoryReleaseDownloadStrategy
      sha256 "REPLACE_ME"
    end
  end

  def install
    bin.install "example-tool"
  end

  test do
    system bin/"example-tool", "--version"
  end
end
```

Release tags on the tap repo must be namespaced per tool (`example-tool-v0.1.0`),
since one repo holds releases for all tools.

### B4. `README.md` — client-facing install instructions

```markdown
# Finally Studio Tap

## Setup (once)

    gh auth login
    echo 'export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)' >> ~/.zshrc
    exec $SHELL

    brew tap finally-studio/tap

## Install

    brew install finally-studio/tap/<tool>

## Update

    brew update && brew upgrade <tool>

## Troubleshooting

**404 or "cannot access finally-studio/homebrew-tap"** — your account has not been
added to the tap, or your token lacks repo access. Contact us.

**sha256 mismatch** — run `brew cleanup -s` and retry, then contact us.
```

`gh auth login` is strongly preferred over a hand-made PAT: the OAuth token does not
expire on a 366-day clock and it configures the git credential helper in the same
step. A client using a PAT instead will eventually hit expiry, at which point *every*
brew command starts erroring — `brew update` fetches all installed taps periodically,
not just on install.

### B5. Push

```bash
cd homebrew-tap-new
git init -b main
git add .
git commit -m "Initial tap scaffold"
git remote add origin https://github.com/finally-studio/homebrew-tap.git
git push -u origin main
```

---

# Part C — Release workflow (goes in each tool repo)

`.github/workflows/release.yml` in `tool-a`, etc. Builds, uploads the asset to the
**tap** repo, then bumps the formula there.

```yaml
name: Release

on:
  push:
    tags: ["v*"]

jobs:
  release:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build
        run: |
          # produce dist/tool-a_darwin_arm64.tar.gz and dist/tool-a_darwin_amd64.tar.gz

      - name: Publish to tap
        env:
          GH_TOKEN: ${{ secrets.TAP_TOKEN }}
          TOOL: tool-a
          TAP: finally-studio/homebrew-tap
        run: |
          set -euo pipefail
          TAG="${TOOL}-${GITHUB_REF_NAME}"
          VERSION="${GITHUB_REF_NAME#v}"

          gh release create "$TAG" --repo "$TAP" --title "$TAG" --notes "" || true
          gh release upload "$TAG" dist/*.tar.gz --repo "$TAP" --clobber

          ARM_SHA=$(shasum -a 256 "dist/${TOOL}_darwin_arm64.tar.gz" | cut -d' ' -f1)
          AMD_SHA=$(shasum -a 256 "dist/${TOOL}_darwin_amd64.tar.gz" | cut -d' ' -f1)

          git clone "https://x-access-token:${GH_TOKEN}@github.com/${TAP}.git" tap
          cd tap
          # Update version, both URLs and both sha256 values in Formula/${TOOL}.rb.
          # Prefer a small script over sed one-liners; the two sha256 lines are
          # identical in shape and trivially easy to swap by accident.
          git config user.name  "finally-studio-bot"
          git config user.email "bot@finally.studio"
          git commit -am "${TOOL} ${VERSION}"
          git push
```

If the tools are Go, GoReleaser handles all of this natively via `brews:` with
`download_strategy: GitHubPrivateRepositoryReleaseDownloadStrategy` and
`custom_require: lib/private_strategy` — use it instead of hand-rolling the above.

---

# Part D — Verification

Run these before onboarding any client.

```bash
# 1. Tap is private
gh repo view finally-studio/homebrew-tap --json visibility

# 2. Team has read, not write
gh api /orgs/finally-studio/teams/clients/repos/finally-studio/homebrew-tap \
  --jq '.permissions'

# 3. Formula is syntactically valid
brew tap finally-studio/tap
brew audit --strict --tap finally-studio/tap

# 4. End-to-end install actually works
brew install finally-studio/tap/example-tool
```

Then repeat step 4 **as a real client account**, not yours — an org owner's token
succeeds regardless of team permissions, so testing only as yourself proves nothing
about whether the grant is correctly scoped.

### Ongoing

Add a scheduled workflow in the tap repo that installs one formula weekly on a clean
runner. The vendored download strategy is the piece most likely to break silently
after a Homebrew release, and you want to find that out before a client does.

### Offboarding a client

```bash
gh api -X DELETE /orgs/finally-studio/teams/clients/memberships/<username>
```

Both the tap fetch and the asset download fail immediately, since both rode the same
grant. Nothing needs cleaning up on their machine.
