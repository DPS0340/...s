#!/usr/bin/env bash

# Enable debug output
PS4="\n\033[1;33m>>\033[0m "; set -x

LOCATION=$(realpath "$0")
DIR=$(dirname "$LOCATION")

nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.05.tar.gz home-manager

nix-channel --update

nix-shell '<home-manager>' -A install

_OS=$(uname | tr '[:upper:]' '[:lower:]')
_ARCH=$(uname -m)
_USER=$(whoami)

SWITCH_COMMAND="home-manager"

if [ $_OS == "darwin" ]; then
    SWITCH_COMMAND="darwin-rebuild"
    if ! command -v darwin-rebuild; then
        nix profile install nix-darwin/master#darwin-rebuild
    fi
fi

$SWITCH_COMMAND switch --flake path://$DIR#$_USER

if [ $_OS == "linux" ]; then
    sudo update-desktop-database ~/.nix-profile/share/applications
fi

go install golang.org/x/tools/gopls@latest

