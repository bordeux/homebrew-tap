# Homebrew Tap

Custom Homebrew formulas with automated updates from GitHub releases.

## Installation

```bash
brew tap bordeux/tap
```

## Available Formulas

| Formula | Description |
|---------|-------------|
| `tmpltool` | Fast template renderer supporting many datasources and functions |

### Installing a Formula

```bash
# Install latest version
brew install bordeux/tap/tmpltool

# Install specific version
brew install bordeux/tap/tmpltool@1.1
```

## Formula Generator

Formulas are automatically generated from GitHub releases using a Python script.

### Setup

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

### Usage

```bash
# Generate all formulas
python scripts/generate_formulas.py

# Generate specific project
python scripts/generate_formulas.py --project tmpltool

# Dry run (preview only)
python scripts/generate_formulas.py --dry-run

# List configured projects
python scripts/generate_formulas.py --list
```

### Configuration

Edit `projects.yaml` to add or configure projects:

```yaml
projects:
  - repo: owner/repo-name
    keep_versions: 2  # Number of past major.minor versions to keep (0 = only latest)

    # Optional overrides (auto-detected from GitHub if not specified):
    # name: custom-name
    # description: "Custom description"
    # license: MIT
    # binary_name: my-binary
    # asset_patterns:
    #   macos_arm64: "darwin-arm64"
    #   macos_x86_64: "darwin-amd64"
    #   linux_arm64: "linux-arm64"
    #   linux_x86_64: "linux-amd64"
```

### Versioned Formulas

When `keep_versions` is set, the generator creates versioned formulas:

- `tool.rb` - Always points to the latest version
- `tool@1.2.rb` - Specific major.minor version

Old versioned formulas are automatically removed when new versions are released.

## CI/CD

The GitHub Actions workflow (`.github/workflows/update-formulas.yml`) can be triggered:

- **Manually**: Actions → "Update Homebrew Formulas" → Run workflow
- **On push**: When `projects.yaml` is modified

Set `GITHUB_TOKEN` for higher API rate limits.
