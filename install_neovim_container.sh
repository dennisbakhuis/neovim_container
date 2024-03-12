#!/bin/sh
# Neovim Container - A devcontainer-like experience for Neovim.
# MIT License - Copyright (c) 2024 Dennis Bakhuis

NEOVIM_CONTAINER_REPO="https://github.com/dennisbakhuis/neovim_container.git"
NEOVIM_CONTAINER_TEMP_FOLDER="neovim_container_temp"
NEOVIM_CONTAINER_TARGET_FOLDER=".neovim"

# Check if git is installed
if ! [ -x "$(command -v git)" ]; then
	echo "Error: git is not installed." >&2
	exit 1
fi

# Check if current folder already contains a .neovim folder
if [ -d "$NEOVIM_CONTAINER_TARGET_FOLDER" ]; then
	echo "Error: $NEOVIM_CONTAINER_TARGET_FOLDER folder already exists." >&2
	exit 1
fi

git clone $NEOVIM_CONTAINER_REPO $NEOVIM_CONTAINER_TEMP_FOLDER
mv $NEOVIM_CONTAINER_TEMP_FOLDER/neovim_container $NEOVIM_CONTAINER_TARGET_FOLDER
mv $NEOVIM_CONTAINER_TEMP_FOLDER/neovim_container.md $NEOVIM_CONTAINER_TARGET_FOLDER/
mv $NEOVIM_CONTAINER_TEMP_FOLDER/LICENSE $NEOVIM_CONTAINER_TARGET_FOLDER/
rm -rf $NEOVIM_CONTAINER_TEMP_FOLDER
