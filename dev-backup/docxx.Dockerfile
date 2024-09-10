FROM ubuntu:jammy

WORKDIR /
RUN apt update
RUN --mount=type=cache,target=/var/cache/apt \
  apt install -y \
  git \
  tar \
  wget \
  xz-utils

WORKDIR /llvm
RUN git clone --depth=1 --branch=llvmorg-18.1.8 https://github.com/llvm/llvm-project.git src

WORKDIR /
ARG DEBIAN_FRONTEND=noninteractive
RUN --mount=type=cache,target=/var/cache/apt \
  apt install -y \
  build-essential \
  cmake \
  man-db \
  pipx \
  python3 \
  sudo
RUN git config --global --add safe.directory /code
RUN --mount=type=cache,target=/var/cache/apt \
  yes | unminimize

WORKDIR /llvm
RUN --mount=type=cache,target=build \
  cmake -Bbuild src/llvm -DCMAKE_BUILD_TYPE=Release -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" \
  && cmake --build build --target install --parallel $(nproc)

RUN adduser docker --uid 1000
RUN echo 'docker ALL=NOPASSWD:ALL' >> /etc/sudoers
USER docker
WORKDIR /home/docker
RUN pipx ensurepath
RUN --mount=type=cache,target=/home/docker/.cache/pip,uid=1000,gid=1000 \
  pipx install \
  poetry
RUN echo export VIRTUAL_ENV=/code/venv >> .bashrc
RUN echo source /code/venv/bin/activate >> .bashrc

ENV TERM=xterm-color
ENTRYPOINT ["/bin/bash", "--login", "-c"]
