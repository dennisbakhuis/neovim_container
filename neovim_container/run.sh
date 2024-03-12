#!/bin/bash
# Docker start script to start the container
#
# This script is called to start (run) the container. It is
# called by the container_up.sh script. This script should
# not be run on its own.
#
# Variables that are available from container_up.sh:
# - PROJECT_NAME (string)          : The name of the project
# - DOCKER_IMAGE_NAME (string)     : The name of the image
# - DOCKER_CONTAINER_NAME (string) : The name of the container
# - PLATFORM (string)              : The platform of the container
#
# Here you can customize the docker run command to your needs.
# This will be saved between each start/stop of the container.

docker run -d \
	--name "$DOCKER_CONTAINER_NAME" \
	--platform="$PLATFORM" \
	-v "$(pwd)":"$WORKSPACE/$PROJECT_NAME" \
	-v "$HOME/.config/nvim":"/root/.config/nvim" \
	-v "$HOME/.config/github-copilot":"/root/.config/github-copilot" \
	-v "$HOME/.ssh":/root/.ssh:ro \
	-v "$HOME/.gitconfig":/root/.gitconfig:ro \
	-v /etc/localtime:/etc/localtime:ro \
	-e SHELL=/bin/bash \
	-e WORKSPACE="$WORKSPACE/$PROJECT_NAME" \
	-e PYTHONPATH="$WORKSPACE/$PROJECT_NAME" \
	--workdir "$WORKSPACE/$PROJECT_NAME" \
	"$DOCKER_IMAGE_NAME" \
	tail -f /dev/null

# I have not tested this but mounting these when sharing the same
# cpu architecture would save downloading/building all plugins for
# Neovim and share the state between host, container(s).
# As I work on an Arm and run x86_64 containers, I cannot use this.
# -v "$HOME/.local/share/nvim":"/root/.local/share/nvim" \
# -v "$HOME/.local/state/nvim":"/root/.local/state/nvim" \
