FROM ubuntu:latest

# Install aptitude stuff
RUN apt update
RUN --mount=type=cache,target=/var/cache/apt \
    apt install -y \
    doxygen \
    python3.11 \
    python3.11-distutils \
    curl

# Install poetry (could it be cached?)
RUN curl -sSL https://install.python-poetry.org | \
    POETRY_HOME=/usr/local/poetry python3.11 -
ENV PATH=/usr/local/poetry/bin:$PATH

# Use poetry to install our stuff
COPY pyproject.toml .
RUN poetry config cache-dir /.cache/poetry
RUN poetry config virtualenvs.create false
RUN --mount=type=cache,target=/.cache/poetry \
    poetry install --only test,lint,main

# Give ruff cache persistence
ENV RUFF_CACHE_DIR=/home/docker/.ruff_cache

# Switch to a non-root user, so the files created inside mounted volume can be easily manipulated
RUN adduser docker
USER docker
WORKDIR /home/docker
