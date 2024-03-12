# Docker build script for the production container
#
# This script is called by container_up.sh to build the container.
#
# Variables that are available from container_up.sh:
# - PROJECT_NAME (string)          : The name of the project
# - DOCKER_IMAGE_NAME (string)     : The name of the image
# - DOCKER_CONTAINER_NAME (string) : The name of the container
# - PLATFORM (string)              : The platform of the container
#
# Example to add your own secret:
# docker build . \
#   --platform="$PLATFORM" \
#   -t $DOCKER_IMAGE_NAME \
#   --secret id=MY_SUPER_SECRET,env=MY_SECRET_STORED_LOCALLY_IN_ENV \
#   --progress=plain

docker build . \
	--platform="$PLATFORM" \
	-t $DOCKER_IMAGE_NAME \
	--progress=plain
