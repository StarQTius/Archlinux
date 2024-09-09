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

RUN adduser docker
RUN echo 'docker ALL=NOPASSWD:ALL' >> /etc/sudoers
USER docker
WORKDIR $HOME
ENV TERM=xterm-color
RUN pipx ensurepath
RUN pipx ensurepath
RUN pipx ensurepath
RUN --mount=type=cache,target=/root/.local/pipx \
  sudo pipx install \
  poetry
