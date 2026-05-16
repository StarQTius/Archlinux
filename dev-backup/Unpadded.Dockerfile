FROM ubuntu:plucky

COPY entrypoint.sh* /entrypoint.sh

WORKDIR /
RUN apt update
RUN --mount=type=cache,id=Unpadded,target=/var/cache/apt \
  apt install -y \
  git \
  software-properties-common \
  wget
RUN add-apt-repository ppa:ubuntu-toolchain-r/test
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key 2>/dev/null | tee /etc/apt/trusted.gpg.d/apt.llvm.org.asc
RUN echo 'deb http://apt.llvm.org/plucky/ llvm-toolchain-plucky-22 main' > /etc/apt/sources.list.d/llvm.list
RUN git clone https://github.com/include-what-you-use/include-what-you-use --branch=0.26
RUN git clone https://github.com/google/bloaty

WORKDIR /
RUN apt update
RUN --mount=type=cache,id=Unpadded,target=/var/cache/apt \
  apt install -y \
  ccache \
  clang-22 \
  clangd \
  clang-format-22 \
  clang-tidy-22 \
  cmake \
  gdb \
  g++-15 \
  libclang-22-dev \
  pipx \
  socat \
  sudo
RUN git config --global --add safe.directory /code
ENV CCACHE_DIR=/code/.ccache

WORKDIR /include-what-you-use
RUN --mount=type=cache,id=Unpadded_iwyu,target=/include-what-you-use/build \
  cmake -Bbuild -DCMAKE_CXX_COMPILER=clang++-22 -DCMAKE_PREFIX_PATH=/usr/lib/llvm-22 \
  && cmake --build build --target install --parallel $(nproc)
RUN ln -s /usr/local/bin/include-what-you-use /usr/bin/iwyu

WORKDIR /bloaty
RUN git checkout 0e5a909
RUN git submodule update --init --recursive
RUN --mount=type=cache,id=Unpadded_bloaty,target=/bloaty/build \
  cmake -Bbuild -DCMAKE_CXX_COMPILER=clang++-22 -DBUILD_TESTING=NO \
  && make install --directory build --jobs $(nproc) --ignore-errors \
  && cmake --build build --target install
RUN ln -s /usr/local/bin/bloaty /usr/bin/bloaty

WORKDIR /
RUN update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-15 0
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-22 0
RUN update-alternatives --install /usr/bin/clang-format clang-format /usr/bin/clang-format-22 0
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-22 0
RUN echo "ubuntu ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ubuntu
WORKDIR /home/ubuntu
RUN pipx ensurepath
RUN --mount=type=cache,id=Unpadded,target=/home/ubuntu/.cache/pip,uid=1000,gid=1000 \
  pipx install cmakelang

ENV TERM=xterm-color
