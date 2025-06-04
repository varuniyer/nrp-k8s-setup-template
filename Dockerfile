# Start from the CUDA devel image
FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

# Set shell
SHELL ["/bin/bash", "-c"]

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends \ 
    locales btop && \
    # Set locale
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set locale environment variables
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8

# Copy dependencies to the working directory and set permissions
WORKDIR /home/ubuntu/work
COPY pyproject.toml ./
RUN chown -R ubuntu:ubuntu /home/ubuntu

# Set user
USER ubuntu

# Set environment variables
ENV UV_NO_CACHE=true UV_NO_BUILD_ISOLATION=true

# Create virtual environment and install dependencies
RUN uv sync

# Set entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]
