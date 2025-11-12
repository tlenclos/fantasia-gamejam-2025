# syntax=docker/dockerfile:1
FROM --platform=linux/amd64 fedora:latest

# Environment variables and parameters
ARG GODOT_VERSION="4.5"
ARG SERVER_PORT=9999
ENV GODOT_FILE_NAME="Godot_v${GODOT_VERSION}-stable_linux.x86_64"

# Name of the PCK file you want to run on the server
ENV GODOT_GAME_NAME="Godot3DMultiplayer.linux" 

# System dependencies we will need
RUN dnf update -y
RUN dnf install -y wget
RUN dnf install -y unzip
RUN dnf install -y wayland-devel
RUN dnf install -y fontconfig

# Download Godot, version is set from environment variables
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}-stable/${GODOT_FILE_NAME}.zip \
    && mkdir -p ~/.cache \
    && mkdir -p ~/.config/godot \
    && unzip ${GODOT_FILE_NAME}.zip \
    && mv ${GODOT_FILE_NAME} /usr/local/bin/godot \
    && rm -f ${GODOT_FILE_NAME}.zip

# Make directory to run the app from and then run the app
WORKDIR /godotapp
# Copy project folder from the context folder
COPY . project/

# Export pck file to be used by Godot
WORKDIR /godotapp/project
RUN godot --headless --export-pack "Server Linux" /godotapp/${GODOT_GAME_NAME}.pck

WORKDIR /godotapp

# Expose ports to be used by the server
EXPOSE ${SERVER_PORT}/udp

# Start server
SHELL ["/bin/bash", "-c"]
ENTRYPOINT godot --main-pack ${GODOT_GAME_NAME}.pck