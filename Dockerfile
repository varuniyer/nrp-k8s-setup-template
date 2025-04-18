FROM nvidia/cuda:12.1.0-base-ubuntu22.04
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

SHELL ["/bin/bash", "-c"]

RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    curl unzip git build-essential && \
    curl -L rclone.org/install.sh | bash && \
    apt-get purge --autoremove -y curl unzip && \
    apt-get clean && rm -rf /var/lib/apt/lists/* && \
    useradd -m user

USER user
WORKDIR /home/user/work

ENV PATH=/home/user/work/.venv/bin:$PATH
COPY pyproject.toml .
RUN uv sync -n && \
    rm pyproject.toml && \
    python -m nltk.downloader punkt_tab