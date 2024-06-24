FROM ubuntu:latest

# Install Kitware Aptitude repository
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null

RUN apt update
RUN apt install sudo -y
RUN apt install pip -y
RUN apt install gcc-11 -y
RUN apt install clang-11 -y
RUN apt install ccache -y
RUN apt install doxygen -y
RUN apt install cmake -y
RUN apt install git -y
RUN apt install gdb -y
RUN apt install clang-format -y
RUN apt install clangd -y
RUN apt install clang-tidy -y
RUN apt install socat -y

RUN pip install pytest
RUN pip install pytest-asyncio
RUN pip install cppimport
RUN pip install cmakelang

RUN git clone https://github.com/include-what-you-use/include-what-you-use
WORKDIR /include-what-you-use
RUN apt install clang-15 -y
RUN apt install libclang-15-dev -y
RUN git checkout clang_15
RUN cmake -B build -DCMAKE_PREFIX_PATH=/usr/lib/llvm-15 
RUN cmake --build build -t install -j4
RUN ln -s /usr/local/bin/include-what-you-use /usr/bin/iwyu
WORKDIR /

RUN git config --global --add safe.directory /code
ENV CCACHE_DIR=/code/.ccache

RUN apt install python3.10 -y
RUN apt install python3.10-venv -y

RUN git clone --depth=1 https://github.com/matus-chochlik/ctcache
WORKDIR /ctcache
RUN cp clang-tidy-cache /usr/local/bin
ENV CTCACHE_DIR=/code/.ctcache
WORKDIR /

RUN pip install black isort

RUN apt install clang-tidy-15 -y
RUN update-alternatives --install /usr/bin/clang-tidy clang-tidy /usr/bin/clang-tidy-15 0
RUN apt install clang -y

RUN apt install wget

# Install Kitware Aptitude repository
RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null
RUN echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ jammy main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null
RUN apt update
RUN apt install cmake -y

RUN adduser docker
RUN echo 'docker ALL=NOPASSWD:ALL' >> /etc/sudoers
USER docker
