FROM python:3.13-slim-bookworm AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    libldap2-dev \
    libsasl2-dev \
    libpcre3-dev \
    && rm -rf /var/lib/apt/lists/*

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

WORKDIR /build

# Copy project files
COPY pyproject.toml README.rst CHANGES.rst LICENSE ./
COPY pypicloud/ pypicloud/

# Build wheel and install everything into a virtual environment
RUN uv venv /opt/pypicloud && \
    VIRTUAL_ENV=/opt/pypicloud uv pip install '.[all_plugins,server]' uwsgi

# --- Runtime stage ---
FROM python:3.13-slim-bookworm

RUN apt-get update && apt-get install -y --no-install-recommends \
    libldap-2.5-0 \
    libsasl2-2 \
    libpcre3 \
    libxml2 \
    && rm -rf /var/lib/apt/lists/*

# Create pypicloud user
RUN groupadd -r pypicloud && useradd -r -g pypicloud -m -d /var/lib/pypicloud pypicloud

# Copy virtual environment from builder
COPY --from=builder /opt/pypicloud /opt/pypicloud

ENV PATH="/opt/pypicloud/bin:$PATH" \
    VIRTUAL_ENV="/opt/pypicloud"

RUN mkdir -p /etc/pypicloud /var/lib/pypicloud /var/log && \
    chown -R pypicloud:pypicloud /var/lib/pypicloud /var/log

WORKDIR /var/lib/pypicloud

EXPOSE 8080

USER pypicloud

CMD ["uwsgi", "--ini", "/etc/pypicloud/config.ini"]
