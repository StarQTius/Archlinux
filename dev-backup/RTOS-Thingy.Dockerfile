FROM rust:1.77.0

# Installing various Aptitude packages
RUN apt update
RUN --mount=type=cache,target=/var/cache/apt \
    apt install -y \
    cargo \
    curl \
    libssl-dev \
    perl \
    pipx \
    tar

# Installation Rust toolchain for xtensa
ENV CARGO_HOME=/.cargo
ENV RUST_BACKTRACE=full
ENV PATH=$CARGO_HOME/bin:$PATH
RUN curl -L --proto '=https' --tlsv1.2 -sSf https://raw.githubusercontent.com/cargo-bins/cargo-binstall/main/install-from-binstall-release.sh | bash
RUN cargo binstall rustfilt espup -y
RUN --mount=type=cache,target=/tmp \
    espup install -t esp32
RUN rustup default esp
RUN apt install -y libusb-1.0-0

# Installing GCC toolchain for xtensa
RUN curl -s -L https://github.com/espressif/crosstool-NG/releases/download/esp-12.2.0_20230208/xtensa-esp32-elf-12.2.0_20230208-x86_64-linux-gnu.tar.xz | tar Jxf -
ENV PATH=/xtensa-esp32-elf/bin:$PATH

# Get ESP-IDF when trying out stuff
RUN git clone -b v5.2.1 --recursive --depth=1 https://github.com/espressif/esp-idf.git
RUN apt install -y python3-venv
ENV IDF_TOOLS_PATH=/esp-tool
ENV IDF_PATH=/esp-idf
RUN esp-idf/install.sh esp32
RUN python3 esp-idf/tools/idf_tools.py install
RUN apt install -y cmake

# Installing OpenOCD
RUN curl -s -L https://github.com/espressif/openocd-esp32/releases/download/v0.12.0-esp32-20240318/openocd-esp32-linux-amd64-0.12.0-esp32-20240318.tar.gz | tar zxf -
ENV PATH=/openocd-esp32/bin:$PATH

# Install GDB client for xtensa
RUN curl -s -L https://github.com/espressif/binutils-gdb/releases/download/esp-gdb-v12.1_20231023/xtensa-esp-elf-gdb-12.1_20231023-x86_64-linux-gnu.tar.gz | tar zxf -
ENV PATH=/xtensa-esp-elf-gdb/bin:$PATH


# Patching ESP-PROG OpenOCD configuration
ARG openocd_conf_filename=openocd-esp32/share/openocd/scripts/interface/ftdi/esp32_devkitj_v1.cfg
RUN sed 's/adapter speed 20000/adapter speed 5000/g' --in-place $openocd_conf_filename

# Installing the ESP binaries utility
ENV PIPX_HOME=/pipx
ENV ESPTOOL_PATH=${PIPX_HOME}/venvs/esptool/bin
RUN pipx install esptool

ENV CARGO_HOME=/home/docker/.cargo
RUN groupmod uucp --gid 986
RUN useradd docker --groups uucp,root
RUN chown -R docker:docker ${ESPTOOL_PATH}

RUN ln -s /xtensa-esp-elf-gdb/bin/xtensa-esp32-elf-gdb /xtensa-esp-elf-gdb/bin/gdb

USER docker
WORKDIR /home/docker
ENV PATH=${ESPTOOL_PATH}:${PATH}
