# Start from the CUDA devel image
FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

# Set shell
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install system dependencies and clean up temporary files
RUN apt-get update \
    && apt-get install -y --no-install-recommends git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set user and working directory
USER ubuntu
WORKDIR /home/ubuntu/work

# Set environment variables
ENV UV_NO_CACHE=true UV_LINK_MODE=copy PYTHONDONTWRITEBYTECODE=1

# Copy pyproject.toml to the working directory
COPY pyproject.toml ./

# Install Python dependencies and clean up temporary files
RUN uv sync && rm -rf /tmp/* /var/tmp/*

# Set entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]

