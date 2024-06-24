FROM ubuntu:latest

# Change aptitude rules so we can cache .deb files
RUN rm /etc/apt/apt.conf.d/docker-clean
RUN echo ' \
    Binary::apt::APT::Keep-Downloaded-Packages "true"; \
    APT::Keep-Downloaded-Packages "true"; \
' >> /etc/apt/apt.conf.d/99-keep-deb

# Install aptitude stuff
RUN apt update
RUN --mount=type=cache,dst=/var/cache/apt \
    apt install -y \
    clang-15 \
    clang-format \
    clang-tidy-15 \
    cmake \
    git \
    libclang-15-dev \
    lld \
    pip \
    wget

# Install ARM GCC 13.2
WORKDIR /root/dl
RUN --mount=type=cache,dst=/root/dl \
    wget --timestamping https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz
RUN --mount=type=cache,dst=/root/dl \
    tar xvf arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz -C /
RUN mv /arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi /arm-gcc
ENV PATH="$PATH:/arm-gcc/bin"

# Install pip stuff
RUN --mount=type=cache,dst=/root/.cache/pip \
    pip install cmakelang

# Make python3 default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3 0

# Make clang-15 default
RUN update-alternatives --install /usr/bin/clang clang /usr/bin/clang-15 0
RUN update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-15 0

# Make clang-tidy-15 default
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-15 0

# Compile and install IWYU
WORKDIR /root
RUN git clone --depth=1 -b clang_15 https://github.com/include-what-you-use/include-what-you-use
WORKDIR /root/include-what-you-use
RUN --mount=type=cache,dst=/root/include-what-you-use/build \
    cmake -B build -DCMAKE_PREFIX_PATH=/usr/lib/llvm-15
RUN --mount=type=cache,dst=/root/include-what-you-use/build \
    cmake --build build -t install -j4
RUN ln -s /usr/local/bin/include-what-you-use /usr/bin/iwyu
RUN mv iwyu_tool.py /usr/bin/

# Install clang-tidy-cache
WORKDIR /root
RUN git clone --depth=1 https://github.com/matus-chochlik/ctcache
WORKDIR /root/ctcache
RUN cp clang-tidy-cache /usr/local/bin
ENV CTCACHE_DIR=/code/.ctcache

# Remove uncached build stuff
RUN rm -rf /root/*

# Switch to non-root user
RUN adduser docker
USER docker
