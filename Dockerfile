# Defaults to the base image for CUDA 12.4 to align with the NRP's GPU nodes
FROM nvidia/cuda:12.4.0-base-ubuntu22.04

# Get repository name (passed in as a build argument)
ARG REPO_NAME
ENV REPO_NAME=$REPO_NAME

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get upgrade -y && \
    # Install NCCL for multi-GPU support
    # apt-get install -y libnccl2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd -m user

USER user
WORKDIR /home/user/work
COPY pyproject.toml entrypoint.sh ./

# Create virtual environment and set entrypoint permissions
RUN uv sync -n && \
    rm pyproject.toml

ENTRYPOINT ["bash", "entrypoint.sh"]
