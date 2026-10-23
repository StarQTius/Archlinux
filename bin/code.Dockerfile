FROM alpine:3.24.0

RUN apk add --no-cache sudo npm git curl bash

RUN npm install -g @anthropic-ai/claude-code

RUN adduser -D claude
RUN echo "claude ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER claude
WORKDIR /home/claude
