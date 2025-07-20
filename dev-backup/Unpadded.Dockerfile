FROM ubuntu:plucky

WORKDIR /
RUN apt update
RUN --mount=type=cache,id=Unpadded,target=/var/cache/apt \
  apt install -y \
  git \
  software-properties-common \
  wget
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key 2>/dev/null | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
RUN echo 'deb http://apt.llvm.org/plucky/ llvm-toolchain-plucky main' > /etc/apt/sources.list.d/llvm.list
RUN git clone --depth=1 --branch=clang_20 https://github.com/include-what-you-use/include-what-you-use

WORKDIR /
RUN apt update
RUN --mount=type=cache,id=Unpadded,target=/var/cache/apt \
  apt install -y \
  ccache \
  clang-20 \
  clangd \
  clang-format \
  clang-tidy \
  cmake \
  gdb \
  g++-15 \
  libclang-20-dev \
  pipx \
  socat \
  sudo
RUN git config --global --add safe.directory /code
ENV CCACHE_DIR=/code/.ccache

WORKDIR /include-what-you-use
RUN --mount=type=cache,id=Unpadded,target=build \
  cmake -Bbuild -DCMAKE_CXX_COMPILER=clang++-20 -DCMAKE_PREFIX_PATH=/usr/lib/llvm-20 \
  && cmake --build build --target install --parallel $(nproc)
RUN ln -s /usr/local/bin/include-what-you-use /usr/bin/iwyu

USER ubuntu
WORKDIR /home/ubuntu
RUN pipx ensurepath
RUN --mount=type=cache,id=Unpadded,target=/home/ubuntu/.cache/pip,uid=1000,gid=1000 \
  pipx install cmakelang

ENV TERM=xterm-color
