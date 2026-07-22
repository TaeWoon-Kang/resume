#!/usr/bin/env bash

set -euo pipefail

if [[ -x /opt/homebrew/opt/ruby@3.3/bin/ruby ]]; then
  RESUME_RUBY_BIN="/opt/homebrew/opt/ruby@3.3/bin"
elif [[ -x /usr/local/opt/ruby@3.3/bin/ruby ]]; then
  RESUME_RUBY_BIN="/usr/local/opt/ruby@3.3/bin"
else
  echo "Ruby 3.3 is required. Install it with: brew install ruby@3.3" >&2
  exit 1
fi

export PATH="${RESUME_RUBY_BIN}:${PATH}"
RESUME_PORT="${RESUME_PORT:-4000}"

bundle check || bundle install

echo "Starting resume site at http://127.0.0.1:${RESUME_PORT}/"
exec bundle exec jekyll serve --host 127.0.0.1 --port "${RESUME_PORT}"
