FROM snakepacker/python:all
LABEL maintainer="Steven Arcangeli <stevearc@stevearc.com>"

RUN apt-install libldap2-dev libsasl2-dev default-jre

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/
