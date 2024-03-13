#!/bin/bash
# Neovim Container - A devcontainer-like experience for Neovim.
# MIT License - Copyright (c) 2024 Dennis Bakhuis

set +e

NEOVIM_CONTAINER_REPO="https://github.com/dennisbakhuis/neovim_container.git"
NEOVIM_CONTAINER_TARGET_FOLDER=".neovim"

FILES_TO_DOWNLOAD=(
	"neovim_container/constants.sh"
	"neovim_container/container.sh"
	"neovim_container/build.sh"
	"neovim_container/install.sh"
	"neovim_container/run.sh"
	"README.md"
	"LICENSE"
)

if ! [ -x "$(command -v wget)" ]; then
	echo "Error: wget is not installed." >&2
	exit 1
fi

if [ -d "$NEOVIM_CONTAINER_TARGET_FOLDER" ]; then
	echo "Error: $NEOVIM_CONTAINER_TARGET_FOLDER folder already exists." >&2
	exit 1
fi

mkdir -p "$NEOVIM_CONTAINER_TARGET_FOLDER/neovim_container"
RAW_CONTENT_URL=$(echo $NEOVIM_CONTAINER_REPO | sed 's/github\.com/raw.githubusercontent.com/' | sed 's/\.git$/\/main/')

for file in "${FILES_TO_DOWNLOAD[@]}"; do
	wget "${RAW_CONTENT_URL}/${file}" --output-document "${NEOVIM_CONTAINER_TARGET_FOLDER}/${file}" --quiet &
done
wait

mv $NEOVIM_CONTAINER_TARGET_FOLDER/neovim_container/* $NEOVIM_CONTAINER_TARGET_FOLDER
rm -rf $NEOVIM_CONTAINER_TARGET_FOLDER/neovim_container

echo "Neovim Container installed in $NEOVIM_CONTAINER_TARGET_FOLDER"
echo "To start the container, run $NEOVIM_CONTAINER_TARGET_FOLDER/container.sh up"
