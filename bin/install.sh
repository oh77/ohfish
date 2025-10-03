#!/usr/bin/env bash

set -e

echo "🚀 Starting Mac setup..."

# Install or update Homebrew
if command -v brew &> /dev/null; then
    echo "✓ Homebrew is installed"
    
    # Check if brew is up to date
    if brew update --dry-run | grep -q "Already up-to-date"; then
        echo "✓ Homebrew is already up to date"
    else
        echo "⟳ Updating Homebrew..."
        brew update
        echo "✓ Homebrew updated"
    fi
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

echo "✅ Mac setup complete!"

