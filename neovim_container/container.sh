#!/bin/sh

SCRIPT_NAME="Neovim_Container - container_up.sh"
SCRIPT_VERSION="0.1.0"

# defaults
NEOVIM_CONTAINER_PATH=".neovim" # Path where build.sh, install.sh, run.sh, and constants.sh are located
BUILD_SCRIPT="$NEOVIM_CONTAINER_PATH/build.sh"
RUN_SCRIPT="$NEOVIM_CONTAINER_PATH/run.sh"
INSTALL_SCRIPT="$NEOVIM_CONTAINER_PATH/install.sh"
CONSTANTS_SCRIPT="$NEOVIM_CONTAINER_PATH/constants.sh"
PLATFORM="linux/amd64"  # Platforms: linux/amd64, linux/arm64, linux/arm/v7, linux/arm/v6
WORKSPACE="/workspaces" # Location to store project files

# Possibly override defaults
if [ -f "$CONSTANTS_SCRIPT" ]; then
	source $CONSTANTS_SCRIPT
fi

# Main
show_help() {
	echo "Usage: $0 [options]"
	echo ""
	echo "Options:"
	echo "  up             Start the container."
	echo "  --project_name   Specify the project name."
	echo "  --rebuild        Force a rebuild of the container."
	exit 0
}

# Parse arguments
up_set=0
while [ $# -gt 0 ]; do
	case "$1" in
	up)
		up_set=1
		;;
	--project_name)
		PROJECT_NAME="$2"
		shift
		;;
	--rebuild)
		REBUILD="yes"
		shift # Move past the argument value
		;;
	*) ;;
	esac
	shift
done

echo $SCRIPT_NAME
echo "Version: $SCRIPT_VERSION"
echo ""

if [ "$up_set" -eq 0 ]; then
	show_help
fi

# Check if Docker is installed
if ! command -v docker >/dev/null 2>&1; then
	echo "Docker is not installed. Exiting."
	exit 1
fi

# Check if there is a dockerfile in the current directory
if [ ! -f Dockerfile ]; then
	echo "Dockerfile not found in current directory. Exiting."
	exit 1
fi

# Get project name from pyproject.toml
if [ -z "$PROJECT_NAME" ]; then
	# Check if git is installed
	if ! command -v git >/dev/null 2>&1; then
		echo "Git is not installed. Exiting."
		exit 1
	fi

	GIT_ROOT=$(git rev-parse --show-toplevel)
	PYPROJECT_PATH="$GIT_ROOT/pyproject.toml"
	PROJECT_NAME=$(grep '^name = ' "$PYPROJECT_PATH" | head -n 1 | awk -F '"' '{print $2}')
fi

if [ -z "$PROJECT_NAME" ]; then
	echo "Project name is not set (or found in pyproject.toml."
	exit 1
fi

echo "Neovim Container - Starting container for $PROJECT_NAME"

DOCKER_IMAGE_NAME="$PROJECT_NAME:latest"
DOCKER_CONTAINER_NAME="$PROJECT_NAME"

# When --force-rebuild, stop all running containers and delete the image
if [ -n "$REBUILD" ]; then
	if docker image inspect "$DOCKER_IMAGE_NAME" >/dev/null 2>&1; then
		echo "Forcing rebuild of the container."
		containers=$(docker ps -a -q --filter "ancestor=$DOCKER_IMAGE_NAME")
		if [ -n "$containers" ]; then
			echo "Stopping containers using the image $DOCKER_IMAGE_NAME"
			docker stop $containers
			echo "Removing containers using the image $DOCKER_IMAGE_NAME"
			docker rm $containers
		fi

		echo "Deleting the image $DOCKER_IMAGE_NAME"
		docker rmi $DOCKER_IMAGE_NAME >/dev/null
	fi
fi

# Typical start session script
start_session() {
	echo "----------------"
	echo ""
	docker exec -it $DOCKER_CONTAINER_NAME /bin/bash
	echo "Stopping Neovim container..."
	docker stop $DOCKER_CONTAINER_NAME
	exit 0
}

# Check if the container exists (including stopped containers) and start session
if docker container ls -a --format '{{.Names}}' | grep -w "$DOCKER_CONTAINER_NAME" >/dev/null; then
	if ! docker container inspect -f '{{.State.Running}}' "$DOCKER_CONTAINER_NAME" | grep true >/dev/null; then
		echo "Container '$DOCKER_CONTAINER_NAME' exists but is stopped. Starting..."
		docker start $DOCKER_CONTAINER_NAME
	fi
	start_session
fi

# Check if container is not yet built and build it when necessary
if ! docker image inspect "$DOCKER_IMAGE_NAME" >/dev/null 2>&1; then
	echo "Building the Neovim container..."
	if [ -f "$BUILD_SCRIPT" ]; then
		source $BUILD_SCRIPT
	else
		echo "No build script found at $BUILD_SCRIPT."
		exit 1
	fi
fi
if ! docker image inspect "$DOCKER_IMAGE_NAME" >/dev/null 2>&1; then
	echo "Error: The container could not be built."
	docker rmi "$DOCKER_IMAGE_NAME" >/dev/null
	exit 1
fi

# Start it for the first time and install the requirements
echo "Starting Neovim container for the first time..."
if [ -f "$RUN_SCRIPT" ]; then
	source $RUN_SCRIPT
else
	echo "No run script found at $($RUN_SCRIPT)."
	exit 1
fi
if ! docker container inspect -f '{{.State.Running}}' "$DOCKER_CONTAINER_NAME" | grep true >/dev/null; then
	echo "Error: The container could not be started."
	docker rm $DOCKER_CONTAINER_NAME >/dev/null
	exit 1
fi

# Install Neovim inside of container
if [ -f "$INSTALL_SCRIPT" ]; then
	docker exec -it $DOCKER_CONTAINER_NAME /bin/bash -c "source $INSTALL_SCRIPT"
else
	echo "No install script found at $($INSTALL_SCRIPT)."
	exit 1
fi

if ! docker exec $DOCKER_CONTAINER_NAME /opt/nvim-linux64/bin/nvim --version >/dev/null 2>&1; then
	echo "Error: Neovim not found inside of container."
	docker stop $DOCKER_CONTAINER_NAME
	docker rm $DOCKER_CONTAINER_NAME
	exit 1
fi

# start_session
start_session
