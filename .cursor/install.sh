#!/usr/bin/env bash
# Copyright (c) Streamlit Inc. (2018-2022) Snowflake Inc. (2022-2026)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -euo pipefail

cd "$(dirname "$0")/.."

# Ensure uv and the repo Node version are on PATH when install runs outside the
# custom image (e.g. during local validation on the default Cloud Agent VM).
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi
if [[ -s "$HOME/.nvm/nvm.sh" && -f .nvmrc ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.nvm/nvm.sh"
  nvm install >/dev/null 2>&1
  NVM_VERSION=$(<.nvmrc)
  NVM_NODE_DIR="$HOME/.nvm/versions/node/${NVM_VERSION}"
  if [[ -d "$NVM_NODE_DIR/bin" ]]; then
    export PATH="$NVM_NODE_DIR/bin:$PATH"
  fi
fi

# Skip Playwright browser install during environment setup for faster, more reliable
# builds. Agents can run `uv run python -m playwright install --with-deps` when
# e2e tests are needed.
export INSTALL_PLAYWRIGHT=false

make init
make frontend-fast

# Configure agent shells so make debug works without manual nvm/corepack setup.
PROFILE_SNIPPET="$HOME/.profile_cursor_env"
cat > "$PROFILE_SNIPPET" << 'EOF'
export PATH="$HOME/.local/bin:$PATH"
if [[ -s "$HOME/.nvm/nvm.sh" && -f /workspace/.nvmrc ]]; then
  # shellcheck disable=SC1091
  source "$HOME/.nvm/nvm.sh"
  NVM_VERSION=$(< /workspace/.nvmrc)
  NVM_NODE_DIR="$HOME/.nvm/versions/node/${NVM_VERSION}"
  if [[ -d "$NVM_NODE_DIR/bin" ]]; then
    export PATH="$NVM_NODE_DIR/bin:$PATH"
  fi
fi
corepack enable yarn >/dev/null 2>&1 || true
EOF
if ! grep -q 'profile_cursor_env' "$HOME/.bashrc" 2>/dev/null; then
  echo '. "$HOME/.profile_cursor_env"' >> "$HOME/.bashrc"
fi
