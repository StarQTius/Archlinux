FROM ubuntu:latest

# Install aptitude stuff
RUN apt update
RUN --mount=type=cache,target=/var/cache/apt \
    apt install -y \
    ccache \
    cmake \
    curl \
    doxygen \
    g++ \
    gcc \
    git \
    libreadline-dev \
    python3-setuptools \
    python3.11 \
    python3.11-dev \
    python3.11-distutils \
    python3.11-venv

# Configure ccache
ENV CCACHE_DIR=/code/.ccache

# Choose Python3.11 over Python3.10
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.11 20

# Install poetry (could it be cached?)
RUN curl -sSL https://install.python-poetry.org | \
    POETRY_HOME=/usr/local/poetry python3.11 -
ENV PATH=/usr/local/poetry/bin:$PATH

# Switch to a non-root user, so the files created inside mounted volume can be easily manipulated
RUN adduser docker
USER docker
WORKDIR /code

# Use poetry to install our stuff
COPY pyproject.toml .
RUN poetry config virtualenvs.create true
RUN poetry config virtualenvs.path ~/poetry-venvs
RUN poetry config cache-dir ~/.cache/poetry
RUN --mount=type=cache,target=~/.cache/poetry \
    poetry install --no-root
RUN rm pyproject.toml

# Install entrypoint script (when run, install the package in editable mode)
COPY --chown=docker entrypoint.sh /home/docker
RUN chmod +x ~/entrypoint.sh

USER root
RUN apt install -y clang-format 
RUN apt install -y gdb
USER docker
