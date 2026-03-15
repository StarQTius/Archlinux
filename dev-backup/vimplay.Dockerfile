FROM rust:trixie

ENV TERM=xterm-color
ENV CARGO_HOME=/code/.cargo

RUN apt update
RUN apt install chromium -y

RUN useradd --create-home --shell /bin/bash paulin
RUN echo "paulin ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER paulin
WORKDIR /home/paulin
