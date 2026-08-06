#!/bin/fish

source $HOME/secret.fish

set --export ANTHROPIC_BASE_URL "https://openrouter.ai/api"
set --export ANTHROPIC_AUTH_TOKEN "$OPENROUTER_API_KEY"
set --export ANTHROPIC_API_KEY ""
set --export ANTHROPIC_DEFAULT_SONNET_MODEL "poolside/laguna-s-2.1"
