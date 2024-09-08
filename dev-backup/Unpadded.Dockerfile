FROM ubuntu:jammy

# Install Kitware Aptitude repository
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null

RUN apt update
RUN apt install sudo -y
RUN apt install pipx -y
RUN apt install gcc-11 -y
RUN apt install ccache -y
RUN apt install doxygen -y
RUN apt install cmake -y
RUN apt install git -y
RUN apt install gdb -y
RUN apt install clang-format -y
RUN apt install clangd -y
RUN apt install clang-tidy -y
RUN apt install socat -y
RUN apt install python3.11 -y
RUN apt install python3.11-venv -y
RUN apt install clang -y
RUN apt install wget -y
RUN apt install clang-15 -y
RUN apt install libclang-15-dev -y
RUN apt install clang-tidy-15 -y
RUN apt install cmake -y

RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-15 0

RUN pipx install cmakelang
RUN pipx install black
RUN pipx install isort

RUN git clone https://github.com/include-what-you-use/include-what-you-use
WORKDIR /include-what-you-use
RUN git checkout clang_15
RUN cmake -B build -DCMAKE_PREFIX_PATH=/usr/lib/llvm-15 
RUN cmake --build build -t install -j4
RUN ln -s /usr/local/bin/include-what-you-use /usr/bin/iwyu
WORKDIR /

RUN git config --global --add safe.directory /code
ENV CCACHE_DIR=/code/.ccache

# Install Kitware Aptitude repository
RUN apt install gpg -y
RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 6AF7F09730B3F0A4
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null

RUN apt update
RUN apt install python3-dev -y
RUN apt install cmake -y
RUN apt install g++ -y

RUN adduser docker
RUN echo 'docker ALL=NOPASSWD:ALL' >> /etc/sudoers
USER docker
