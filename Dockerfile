# Start from the CUDA devel image
FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

# Declare build arguments
ARG REPO_NAME

# Set shell
SHELL ["/bin/bash", "-c"]

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Upgrade packages
RUN apt-get update && apt-get upgrade -y --no-install-recommends && \
    # Install packages
    apt-get install -y --no-install-recommends \ 
    build-essential && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy dependencies to the working directory and set permissions
WORKDIR /home/ubuntu/work
COPY pyproject.toml ./
RUN chown -R ubuntu:ubuntu /home/ubuntu

# Set user
USER ubuntu

# Set environment variables
ENV REPO_NAME=$REPO_NAME
ENV UV_NO_CACHE=true UV_NO_BUILD_ISOLATION=true

# Create virtual environment and install dependencies
RUN uv sync

# Set entrypoint
ENTRYPOINT exec bash ${REPO_NAME}/entrypoint.sh
