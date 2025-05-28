# Start from the CUDA base image
FROM nvidia/cuda:12.8.1-base-ubi9

# Declare build arguments
ARG REPO_NAME

# Set shell
SHELL ["/bin/bash", "-c"]

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Update and add user
RUN dnf update -y && dnf clean all && useradd -m user

# Copy dependencies to the working directory and set permissions
WORKDIR /home/user/work
COPY pyproject.toml entrypoint.sh ./
RUN chown -R user:user . && chmod +x entrypoint.sh

# Set user
USER user

# Set environment variables
ENV REPO_NAME=$REPO_NAME
ENV UV_NO_CACHE=true
ENV UV_NO_BUILD_ISOLATION=true

# Create virtual environment and install dependencies
RUN uv sync

# Set entrypoint
ENTRYPOINT ["./entrypoint.sh"]

