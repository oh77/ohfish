#!/usr/bin/env bash

set -e

REPO_URL="https://github.com/oh77/ohfish"
TARBALL_URL="https://codeload.github.com/oh77/ohfish/tar.gz/refs/heads/main"
REPO_DIR="${OHFISH_DIR:-$HOME/.ohfish}"

echo "🚀 Starting Mac setup..."

# Detect if we're running from the repo or need to download it
if [ -f "$(dirname "$0")/../Brewfile" ]; then
    # Running locally from repo
    echo "✓ Running from local repository"
    SCRIPT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
else
    # Need to download the repo
    echo "⟳ Downloading ohfish repository..."
    
    mkdir -p "$REPO_DIR"
    
    if command -v git &> /dev/null; then
        # Use git if available
        if [ -d "$REPO_DIR/.git" ]; then
            echo "✓ Repository exists, updating..."
            git -C "$REPO_DIR" fetch --prune --quiet || true
            git -C "$REPO_DIR" pull --ff-only --quiet || echo "✓ Repository up to date"
        else
            git clone "$REPO_URL" "$REPO_DIR"
        fi
    else
        # Fallback: download tarball
        TMPDIR="$(mktemp -d)"
        curl -fsSL "$TARBALL_URL" -o "$TMPDIR/ohfish.tar.gz"
        tar -xzf "$TMPDIR/ohfish.tar.gz" -C "$TMPDIR"
        SRC_DIR="$(find "$TMPDIR" -maxdepth 1 -type d -name "ohfish-*" | head -n1)"
        
        if [ -z "$SRC_DIR" ]; then
            echo "❌ Failed to extract repository"
            exit 1
        fi
        
        (cd "$SRC_DIR" && tar -cf - .) | (cd "$REPO_DIR" && tar -xf -)
        rm -rf "$TMPDIR"
    fi
    
    SCRIPT_DIR="$REPO_DIR"
    echo "✓ Repository ready at $REPO_DIR"
fi

# Install or update Homebrew
if command -v brew &> /dev/null; then
    echo "✓ Homebrew is installed"
    echo "⟳ Updating Homebrew..."
    brew update --quiet || true
    echo "✓ Homebrew updated"
else
    echo "⟳ Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    echo "✓ Homebrew installed"
fi

# Install packages from Brewfile
if [ -f "$SCRIPT_DIR/Brewfile" ]; then
    echo "⟳ Installing packages from Brewfile..."
    brew bundle --file="$SCRIPT_DIR/Brewfile"
    echo "✓ Packages installed"
else
    echo "⚠ Brewfile not found, skipping package installation"
fi

echo "✅ Mac setup complete!"

