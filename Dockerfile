FROM nvidia/cuda:12.4.0-base-ubuntu22.04
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    # Install NCCL for multi-GPU support
    libnccl2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd -m user

USER user
WORKDIR /home/user/work

ENV PATH=/home/user/work/.venv/bin:$PATH
COPY pyproject.toml .
RUN uv sync -n && \
    rm pyproject.toml 