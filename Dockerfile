# Start from the CUDA devel image
FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

# Set shell
SHELL ["/bin/bash", "-c"]

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Mount tmpfs to reduce the final image size
RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/var/tmp \
    # Install packages
    apt-get update && apt-get install -y --no-install-recommends \ 
    locales btop && \
    # Set locale
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    # Clean up apt cache
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set all environment variables
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV UV_NO_CACHE=true UV_LINK_MODE=copy UV_NO_BUILD_ISOLATION=true

# Set user and working directory
USER ubuntu
WORKDIR /home/ubuntu/work

# Copy pyproject.toml to the working directory
COPY pyproject.toml ./

# Mount tmpfs to reduce the final image size
RUN --mount=type=tmpfs,dst=/tmp --mount=type=tmpfs,dst=/var/tmp \
    # Create virtualenv with dependencies from pyproject.toml
    uv sync && \
    # Clean up __pycache__ directories
    find ~ -name __pycache__ -type d -exec rm -rf {} +

# Set entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]
