FROM ubuntu:plucky

WORKDIR /
RUN apt update
RUN --mount=type=cache,id=Unpadded,target=/var/cache/apt \
  apt install -y \
  git \
  software-properties-common \
  wget
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | gpg --dearmor | sudo tee /usr/share/keyrings/llvm-archive-keyring.gpg
RUN echo 'deb http://apt.llvm.org/noble/ llvm-toolchain-noble-19 main' > /etc/apt/sources.list.d/llvm.list
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ noble main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null
RUN git clone --depth=1 --branch=clang_18 https://github.com/include-what-you-use/include-what-you-use

WORKDIR /
RUN apt update
RUN --mount=type=cache,id=Unpadded,target=/var/cache/apt \
  apt install -y \
  ccache \
  clang-18 \
  clang-19 \
  clangd \
  clang-format \
  clang-tidy \
  cmake \
  gdb \
  g++-15 \
  libclang-18-dev \
  pipx \
  socat \
  sudo
RUN git config --global --add safe.directory /code
ENV CCACHE_DIR=/code/.ccache

WORKDIR /include-what-you-use
RUN --mount=type=cache,id=Unpadded,target=build \
  cmake -Bbuild -DCMAKE_CXX_COMPILER=clang++-18 -DCMAKE_PREFIX_PATH=/usr/lib/llvm-18 \
  && cmake --build build --target install --parallel $(nproc)
RUN ln -s /usr/local/bin/include-what-you-use /usr/bin/iwyu

# RUN echo 'docker ALL=NOPASSWD:ALL' >> /etc/sudoers
USER ubuntu
WORKDIR /home/ubuntu
RUN pipx ensurepath
RUN --mount=type=cache,id=Unpadded,target=/home/ubuntu/.cache/pip,uid=1000,gid=1000 \
  pipx install cmakelang

ENV TERM=xterm-color
