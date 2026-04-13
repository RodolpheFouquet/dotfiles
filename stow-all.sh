#!/bin/sh
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

for dir in "$DOTFILES_DIR"/*/; do
    name=$(basename "$dir")
    echo "Stowing $name..."
    stow -v -d "$DOTFILES_DIR" -t ~ "$name"
done

echo "Done."
