# Start from the CUDA devel image
FROM nvidia/cuda:12.8.1-devel-ubi9

# Declare build arguments
ARG REPO_NAME

# Set shell
SHELL ["/bin/bash", "-c"]

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Install packages (add more if needed)
RUN dnf install -y --setopt=install_weak_deps=False \
    git && \
    # Clean up
    rpm -e --nodeps dnf dnf-data && \
    rm -rf /var/cache/dnf /var/lib/dnf && \
    rm -rf /tmp/* /var/tmp/* /root/.cache && \
    # Add user
    useradd -m user && \
    # Load CUDA libraries
    ldconfig

# Copy dependencies to the working directory and set permissions
WORKDIR /home/user/work
COPY pyproject.toml entrypoint.sh ./
RUN chown -R user:user . && chmod +x entrypoint.sh

# Set user
USER user

# Set environment variables
ENV REPO_NAME=$REPO_NAME
ENV UV_NO_CACHE=true UV_NO_BUILD_ISOLATION=true UV_TORCH_BACKEND=cu128

# Create virtual environment and install dependencies
RUN uv sync

# Set entrypoint
ENTRYPOINT ["./entrypoint.sh"]
