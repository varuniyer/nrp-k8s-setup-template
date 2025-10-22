# Start from the CUDA devel image
FROM nvidia/cuda:12.8.1-devel-ubuntu24.04

# Set shell
SHELL ["/bin/bash", "-c"]
ENV DEBIAN_FRONTEND=noninteractive

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

RUN printf 'Acquire::ForceIPv4 "true";\nAcquire::Retries "5";\nAcquire::http::Timeout "30";\nAcquire::http::Pipeline-Depth "0";\n' > /etc/apt/apt.conf.d/99ci-apt && \
    # Install packages
    apt-get update && apt-get install -y --no-install-recommends \ 
    locales && \
    # Set locale
    sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
    locale-gen && \
    # Clean up apt cache and temp files
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set all environment variables
ENV LANG=en_US.UTF-8 LANGUAGE=en_US:en LC_ALL=en_US.UTF-8
ENV UV_NO_CACHE=true UV_LINK_MODE=copy UV_NO_BUILD_ISOLATION=true
ENV PYTHONDONTWRITEBYTECODE=1

# Set user and working directory
USER ubuntu
WORKDIR /home/ubuntu/work

# Copy pyproject.toml to the working directory
COPY pyproject.toml ./

# Create virtualenv with dependencies from pyproject.toml
RUN uv sync && \
    # Clean up temp files
    rm -rf /tmp/* /var/tmp/*

# Set entrypoint
ENTRYPOINT ["bash", "entrypoint.sh"]

