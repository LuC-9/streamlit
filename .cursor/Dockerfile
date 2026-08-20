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

FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PYTHONUNBUFFERED=1
ENV COREPACK_ENABLE_DOWNLOAD_PROMPT=0

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    make \
    python3 \
    python3-pip \
    python3-venv \
    python-is-python3 \
    rsync \
    unzip \
    protobuf-compiler \
    ripgrep \
    ca-certificates \
    gnupg \
    lsof \
    && rm -rf /var/lib/apt/lists/*

# Install Node.js 24 (matches .nvmrc)
RUN curl -fsSL https://deb.nodesource.com/setup_24.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && corepack enable

# Install uv for Python dependency management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:${PATH}"

# Create ubuntu user (Cloud Agent default)
RUN useradd -m -s /bin/bash ubuntu \
    && mkdir -p /workspace \
    && chown ubuntu:ubuntu /workspace

USER ubuntu
WORKDIR /workspace

# Enable corepack for Yarn 4 (required by frontend/package.json)
RUN corepack enable
