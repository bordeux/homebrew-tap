#!/usr/bin/env python3
"""
Homebrew Formula Generator

Automatically generates Homebrew formulas from GitHub releases.
Fetches release assets, computes SHA256 checksums, and creates formula files.

Usage:
    python generate_formulas.py                    # Generate all formulas
    python generate_formulas.py --project repo     # Generate specific project
    python generate_formulas.py --list             # List configured projects
"""

import argparse
import hashlib
import os
import re
import sys
from dataclasses import dataclass, field
from pathlib import Path
from typing import Optional, Union
from urllib.request import urlopen, Request
from urllib.error import HTTPError
import json

import yaml


# Platform detection patterns (order matters - more specific first)
PLATFORM_PATTERNS = {
    "macos_arm64": [
        r"darwin.*arm64", r"darwin.*aarch64", r"macos.*arm64", r"macos.*aarch64",
        r"apple.*arm64", r"apple.*aarch64", r"osx.*arm64", r"osx.*aarch64",
        r"mac.*arm64", r"mac.*aarch64",
    ],
    "macos_x86_64": [
        r"darwin.*x86_64", r"darwin.*amd64", r"macos.*x86_64", r"macos.*amd64",
        r"apple.*x86_64", r"apple.*amd64", r"osx.*x86_64", r"osx.*amd64",
        r"mac.*x86_64", r"mac.*amd64", r"darwin64",
    ],
    "linux_arm64": [
        r"linux.*arm64", r"linux.*aarch64",
    ],
    "linux_x86_64": [
        r"linux.*x86_64", r"linux.*amd64", r"linux64",
    ],
}

# Valid archive extensions
ARCHIVE_EXTENSIONS = [".tar.gz", ".tgz", ".zip", ".tar.xz", ".tar.bz2"]


@dataclass
class Asset:
    """Represents a release asset."""
    name: str
    url: str
    sha256: str = ""


@dataclass
class Release:
    """Represents a GitHub release."""
    tag: str
    version: str
    major_minor: str  # e.g., "1.2" from "1.2.3"
    assets: dict[str, Asset] = field(default_factory=dict)


@dataclass
class Project:
    """Represents a project configuration."""
    repo: str
    name: str = ""
    description: str = ""
    license: str = ""
    homepage: str = ""
    binary_name: str = ""
    keep_versions: int = 0  # Number of past major.minor versions to keep (0 = only latest)
    asset_patterns: dict[str, str] = field(default_factory=dict)

    def __post_init__(self):
        if not self.name:
            self.name = self.repo.split("/")[-1]
        if not self.binary_name:
            self.binary_name = self.name
        if not self.homepage:
            self.homepage = f"https://github.com/{self.repo}"


class GitHubAPI:
    """GitHub API client."""

    def __init__(self, token: Optional[str] = None):
        self.token = token or os.environ.get("GITHUB_TOKEN")
        self.base_url = "https://api.github.com"

    def _request(self, endpoint: str) -> Union[dict, list]:
        """Make a request to the GitHub API."""
        url = f"{self.base_url}/{endpoint}"
        headers = {"Accept": "application/vnd.github.v3+json"}
        if self.token:
            headers["Authorization"] = f"token {self.token}"

        req = Request(url, headers=headers)
        try:
            with urlopen(req) as response:
                return json.loads(response.read().decode())
        except HTTPError as e:
            if e.code == 404:
                raise ValueError(f"Repository or release not found: {endpoint}")
            elif e.code == 403:
                raise ValueError("GitHub API rate limit exceeded. Set GITHUB_TOKEN env var.")
            raise

    def get_repo(self, repo: str) -> dict:
        """Get repository information."""
        return self._request(f"repos/{repo}")

    def get_latest_release(self, repo: str) -> dict:
        """Get the latest release for a repository."""
        return self._request(f"repos/{repo}/releases/latest")

    def get_releases(self, repo: str, per_page: int = 30) -> list[dict]:
        """Get releases for a repository."""
        return self._request(f"repos/{repo}/releases?per_page={per_page}")


def compute_sha256(url: str) -> str:
    """Download a file and compute its SHA256 checksum."""
    print(f"    Downloading {url.split('/')[-1]}...")
    req = Request(url, headers={"Accept": "application/octet-stream"})

    sha256 = hashlib.sha256()
    with urlopen(req) as response:
        while chunk := response.read(8192):
            sha256.update(chunk)

    return sha256.hexdigest()


def detect_platform(asset_name: str) -> Optional[str]:
    """Detect the platform from an asset name."""
    name_lower = asset_name.lower()

    # Skip non-archive files
    if not any(name_lower.endswith(ext) for ext in ARCHIVE_EXTENSIONS):
        return None

    for platform, patterns in PLATFORM_PATTERNS.items():
        for pattern in patterns:
            if re.search(pattern, name_lower):
                return platform

    return None


def match_asset_pattern(asset_name: str, pattern: str) -> bool:
    """Check if an asset name matches a custom pattern."""
    return pattern.lower() in asset_name.lower()


def find_release_assets(release_data: dict, project: Project) -> dict[str, Asset]:
    """Find and categorize release assets by platform."""
    assets = {}

    for asset in release_data.get("assets", []):
        name = asset["name"]
        url = asset["browser_download_url"]

        # Use custom patterns if specified
        if project.asset_patterns:
            for platform, pattern in project.asset_patterns.items():
                if match_asset_pattern(name, pattern):
                    assets[platform] = Asset(name=name, url=url)
                    break
        else:
            # Auto-detect platform
            platform = detect_platform(name)
            if platform:
                assets[platform] = Asset(name=name, url=url)

    return assets


def extract_version(tag: str) -> str:
    """Extract version number from a tag (removes 'v' prefix if present)."""
    return tag.lstrip("v")


def extract_major_minor(version: str) -> str:
    """Extract major.minor from a version string (e.g., '1.2' from '1.2.3')."""
    parts = version.split(".")
    if len(parts) >= 2:
        return f"{parts[0]}.{parts[1]}"
    return version


def generate_formula(project: Project, release: Release, is_versioned: bool = False) -> str:
    """Generate a Homebrew formula Ruby file."""
    if is_versioned:
        # Versioned formula: Tmpltool@1.2 -> TmpltoolAT12
        class_name = "".join(word.capitalize() for word in re.split(r"[-_]", project.name))
        class_name += f"AT{release.major_minor.replace('.', '')}"
    else:
        class_name = "".join(word.capitalize() for word in re.split(r"[-_]", project.name))

    formula = f'''class {class_name} < Formula
  desc "{project.description}"
  homepage "{project.homepage}"
  license "{project.license}"
  version "{release.version}"

'''

    # macOS block
    macos_arm = release.assets.get("macos_arm64")
    macos_x86 = release.assets.get("macos_x86_64")

    if macos_arm or macos_x86:
        formula += "  on_macos do\n"
        if macos_arm and macos_x86:
            formula += "    if Hardware::CPU.arm?\n"
            formula += f'      url "{macos_arm.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'      sha256 "{macos_arm.sha256}"\n'
            formula += "    else\n"
            formula += f'      url "{macos_x86.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'      sha256 "{macos_x86.sha256}"\n'
            formula += "    end\n"
        elif macos_arm:
            formula += f'    url "{macos_arm.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'    sha256 "{macos_arm.sha256}"\n'
        else:
            formula += f'    url "{macos_x86.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'    sha256 "{macos_x86.sha256}"\n'
        formula += "  end\n\n"

    # Linux block
    linux_arm = release.assets.get("linux_arm64")
    linux_x86 = release.assets.get("linux_x86_64")

    if linux_arm or linux_x86:
        formula += "  on_linux do\n"
        if linux_arm and linux_x86:
            formula += "    if Hardware::CPU.arm?\n"
            formula += f'      url "{linux_arm.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'      sha256 "{linux_arm.sha256}"\n'
            formula += "    else\n"
            formula += f'      url "{linux_x86.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'      sha256 "{linux_x86.sha256}"\n'
            formula += "    end\n"
        elif linux_arm:
            formula += f'    url "{linux_arm.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'    sha256 "{linux_arm.sha256}"\n'
        else:
            formula += f'    url "{linux_x86.url.replace(release.tag, "v#{version}")}"\n'
            formula += f'    sha256 "{linux_x86.sha256}"\n'
        formula += "  end\n\n"

    # Install block
    formula += f'''  def install
    bin.install "{project.binary_name}"
  end

  test do
    assert_match version.to_s, shell_output("#{{bin}}/{project.binary_name} --version")
  end
end
'''

    return formula


def load_config(config_path: Path) -> list[Project]:
    """Load project configuration from YAML file."""
    with open(config_path) as f:
        data = yaml.safe_load(f)

    projects = []
    for item in data.get("projects", []):
        if isinstance(item, str):
            projects.append(Project(repo=item))
        else:
            projects.append(Project(
                repo=item["repo"],
                name=item.get("name", ""),
                description=item.get("description", ""),
                license=item.get("license", ""),
                homepage=item.get("homepage", ""),
                binary_name=item.get("binary_name", ""),
                keep_versions=item.get("keep_versions", 0),
                asset_patterns=item.get("asset_patterns", {}),
            ))

    return projects


def find_existing_versioned_formulas(formula_dir: Path, project_name: str) -> list[Path]:
    """Find all existing versioned formulas for a project."""
    pattern = f"{project_name}@*.rb"
    return list(formula_dir.glob(pattern))


def cleanup_old_versions(
    formula_dir: Path,
    project_name: str,
    keep_versions: list[str],
    dry_run: bool = False
) -> list[Path]:
    """Remove versioned formulas that are no longer needed."""
    existing = find_existing_versioned_formulas(formula_dir, project_name)
    removed = []

    for formula_path in existing:
        # Extract version from filename (e.g., "tmpltool@1.2.rb" -> "1.2")
        match = re.search(rf"{re.escape(project_name)}@(\d+\.\d+)\.rb$", formula_path.name)
        if match:
            version = match.group(1)
            if version not in keep_versions:
                if dry_run:
                    print(f"  Would remove: {formula_path.name}")
                else:
                    formula_path.unlink()
                    print(f"  Removed: {formula_path.name}")
                removed.append(formula_path)

    return removed


def process_project(project: Project, github: GitHubAPI, formula_dir: Path, dry_run: bool = False) -> bool:
    """Process a single project and generate its formula(s)."""
    print(f"\nProcessing {project.repo}...")

    try:
        # Get repo info for description and license if not specified
        if not project.description or not project.license:
            repo_info = github.get_repo(project.repo)
            if not project.description:
                project.description = repo_info.get("description", "") or f"{project.name} CLI tool"
            if not project.license:
                license_info = repo_info.get("license", {})
                project.license = license_info.get("spdx_id", "MIT") if license_info else "MIT"

        # Get releases (fetch more if we need to keep versions)
        releases_data = github.get_releases(project.repo, per_page=30)
        if not releases_data:
            print(f"  ERROR: No releases found")
            return False

        # Group releases by major.minor, keeping the latest patch for each
        releases_by_minor: dict[str, dict] = {}
        for release_data in releases_data:
            if release_data.get("prerelease") or release_data.get("draft"):
                continue

            tag = release_data["tag_name"]
            version = extract_version(tag)
            major_minor = extract_major_minor(version)

            # Keep only the first (latest) release for each major.minor
            if major_minor not in releases_by_minor:
                releases_by_minor[major_minor] = release_data

        if not releases_by_minor:
            print(f"  ERROR: No valid releases found")
            return False

        # Sort versions (newest first)
        sorted_versions = sorted(
            releases_by_minor.keys(),
            key=lambda v: [int(x) for x in v.split(".")],
            reverse=True
        )

        latest_version = sorted_versions[0]
        print(f"  Latest version: {latest_version}")

        # Determine which versions to generate
        versions_to_keep = sorted_versions[:project.keep_versions + 1]  # +1 for latest
        print(f"  Versions to generate: {', '.join(versions_to_keep)}")

        # Process each version
        generated_releases: dict[str, Release] = {}

        for major_minor in versions_to_keep:
            release_data = releases_by_minor[major_minor]
            tag = release_data["tag_name"]
            version = extract_version(tag)

            print(f"\n  Processing v{version}...")

            # Find assets
            assets = find_release_assets(release_data, project)
            if not assets:
                print(f"    WARNING: No compatible assets found, skipping")
                continue

            print(f"    Found assets for: {', '.join(assets.keys())}")

            # Compute SHA256 for each asset
            for platform, asset in assets.items():
                asset.sha256 = compute_sha256(asset.url)
                print(f"    {platform}: {asset.sha256[:16]}...")

            # Create release object
            release = Release(
                tag=tag,
                version=version,
                major_minor=major_minor,
                assets=assets
            )
            generated_releases[major_minor] = release

        if not generated_releases:
            print(f"  ERROR: No releases could be processed")
            return False

        # Generate formulas
        for major_minor, release in generated_releases.items():
            is_latest = (major_minor == latest_version)

            # Always generate the main formula for the latest version
            if is_latest:
                formula_content = generate_formula(project, release, is_versioned=False)
                if dry_run:
                    print(f"\n--- {project.name}.rb (latest: {release.version}) ---")
                    print(formula_content)
                else:
                    formula_path = formula_dir / f"{project.name}.rb"
                    with open(formula_path, "w") as f:
                        f.write(formula_content)
                    print(f"  Generated: {formula_path.name}")

            # Generate versioned formula if keep_versions > 0
            if project.keep_versions > 0:
                formula_content = generate_formula(project, release, is_versioned=True)
                if dry_run:
                    print(f"\n--- {project.name}@{major_minor}.rb ---")
                    print(formula_content)
                else:
                    formula_path = formula_dir / f"{project.name}@{major_minor}.rb"
                    with open(formula_path, "w") as f:
                        f.write(formula_content)
                    print(f"  Generated: {formula_path.name}")

        # Cleanup old versions
        if project.keep_versions > 0:
            versions_to_keep_set = set(generated_releases.keys())
            cleanup_old_versions(formula_dir, project.name, versions_to_keep_set, dry_run)

        return True

    except Exception as e:
        print(f"  ERROR: {e}")
        import traceback
        traceback.print_exc()
        return False


def main():
    parser = argparse.ArgumentParser(
        description="Generate Homebrew formulas from GitHub releases"
    )
    parser.add_argument(
        "--config", "-c",
        type=Path,
        default=Path(__file__).parent.parent / "projects.yaml",
        help="Path to projects.yaml config file"
    )
    parser.add_argument(
        "--project", "-p",
        type=str,
        help="Process only the specified project (repo name or project name)"
    )
    parser.add_argument(
        "--list", "-l",
        action="store_true",
        help="List all configured projects"
    )
    parser.add_argument(
        "--dry-run", "-n",
        action="store_true",
        help="Print formulas to stdout instead of writing files"
    )
    parser.add_argument(
        "--formula-dir", "-d",
        type=Path,
        default=Path(__file__).parent.parent / "Formula",
        help="Directory to write formula files"
    )

    args = parser.parse_args()

    # Load configuration
    if not args.config.exists():
        print(f"Error: Config file not found: {args.config}")
        sys.exit(1)

    projects = load_config(args.config)

    if args.list:
        print("Configured projects:")
        for p in projects:
            versions_info = f", keep_versions: {p.keep_versions}" if p.keep_versions else ""
            print(f"  - {p.repo} (name: {p.name}{versions_info})")
        return

    # Filter to specific project if requested
    if args.project:
        projects = [
            p for p in projects
            if args.project in (p.repo, p.name, p.repo.split("/")[-1])
        ]
        if not projects:
            print(f"Error: Project '{args.project}' not found in config")
            sys.exit(1)

    # Ensure formula directory exists
    if not args.dry_run:
        args.formula_dir.mkdir(parents=True, exist_ok=True)

    # Initialize GitHub API
    github = GitHubAPI()

    # Process each project
    success_count = 0
    for project in projects:
        if process_project(project, github, args.formula_dir, args.dry_run):
            success_count += 1

    print(f"\nProcessed {success_count}/{len(projects)} projects successfully")

    if success_count < len(projects):
        sys.exit(1)


if __name__ == "__main__":
    main()
