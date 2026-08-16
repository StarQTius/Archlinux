FROM alpine:3.24.0

RUN apk add --no-cache npm git curl bash

RUN npm install -g @anthropic-ai/claude-code

RUN adduser -D claude
USER claude
WORKDIR /home/claude
