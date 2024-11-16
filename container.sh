#!/bin/bash

# Define variables
CONTAINER_NAME="ros2-persistent"
IMAGE_NAME="ros2-humble-usb-gpio:latest"
WORKSPACE_PATH="/path/to/workspace"  # Change this to your desired host path
DISPLAY_VAR=$DISPLAY

# Function to check if the container exists
container_exists() {
    docker ps -a --format '{{.Names}}' | grep -w "$CONTAINER_NAME" > /dev/null
}

# Function to check if the container is running
container_running() {
    docker ps --format '{{.Names}}' | grep -w "$CONTAINER_NAME" > /dev/null
}

# Create and start the container
create_container() {
    echo "Creating the container '$CONTAINER_NAME'..."
    docker run -it --name "$CONTAINER_NAME" \
        --env="DISPLAY=$DISPLAY_VAR" \
        --volume="/tmp/.X11-unix:/tmp/.X11-unix:rw" \
        --volume="$WORKSPACE_PATH:/root/workspace" \
        --device=/dev/gpiomem:/dev/gpiomem \
        --device=/dev/bus/usb:/dev/bus/usb \
        --privileged \
        --group-add dialout \
        --group-add plugdev \
        "$IMAGE_NAME"
}

# Start the container
start_container() {
    echo "Starting the container '$CONTAINER_NAME'..."
    docker start -ai "$CONTAINER_NAME"
}

# Stop the container
stop_container() {
    echo "Stopping the container '$CONTAINER_NAME'..."
    docker stop "$CONTAINER_NAME"
}

# Commit the container as a new image
commit_container() {
    echo "Saving the container as a new image..."
    docker commit "$CONTAINER_NAME" "$IMAGE_NAME"
    echo "Container saved as image: $IMAGE_NAME"
}

# Display help
show_help() {
    echo "Usage: $0 [command]"
    echo "Commands:"
    echo "  create   - Create and start the container"
    echo "  start    - Start the existing container"
    echo "  stop     - Stop the running container"
    echo "  commit   - Save the container as a new image"
    echo "  status   - Display the status of the container"
    echo "  help     - Show this help message"
}

# Check command-line arguments
case "$1" in
    create)
        if container_exists; then
            echo "Container '$CONTAINER_NAME' already exists. Use 'start' to start it."
        else
            create_container
        fi
        ;;
    start)
        if container_running; then
            echo "Container '$CONTAINER_NAME' is already running."
        else
            start_container
        fi
        ;;
    stop)
        if container_running; then
            stop_container
        else
            echo "Container '$CONTAINER_NAME' is not running."
        fi
        ;;
    commit)
        if container_exists; then
            commit_container
        else
            echo "Container '$CONTAINER_NAME' does not exist. Cannot commit."
        fi
        ;;
    status)
        if container_running; then
            echo "Container '$CONTAINER_NAME' is running."
        elif container_exists; then
            echo "Container '$CONTAINER_NAME' exists but is stopped."
        else
            echo "Container '$CONTAINER_NAME' does not exist."
        fi
        ;;
    help)
        show_help
        ;;
    *)
        echo "Invalid command. Use 'help' to see available commands."
        ;;
esac
