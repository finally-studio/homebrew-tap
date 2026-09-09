# Finally Studio Tap

Private Homebrew tap for Finally Studio client tooling.

## Setup (once per client)

Authenticate with GitHub and configure Homebrew to use your token:

```bash
gh auth login
echo 'export HOMEBREW_GITHUB_API_TOKEN=$(gh auth token)' >> ~/.zshrc
exec $SHELL
```

Add the tap:

```bash
brew tap finally-studio/tap
```

## Install

```bash
brew install finally-studio/tap/add-recent-pr-production
```

## Update

```bash
brew update && brew upgrade add-recent-pr-production
```

## Troubleshooting

**404 or "cannot access finally-studio/homebrew-tap"**
Your GitHub account has not been added to the tap, or your token lacks repo access. Contact Finally Studio support.

**"HOMEBREW_GITHUB_API_TOKEN is required"**
The environment variable is not set. Verify:
```bash
echo $HOMEBREW_GITHUB_API_TOKEN
gh auth token
```

**sha256 mismatch**
Run `brew cleanup -s` and retry. If it persists, contact Finally Studio support.
