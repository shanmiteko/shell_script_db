#!/bin/bash

podman build \
        --build-arg UID=$(id -u) \
        --build-arg GID=$(id -g) \
        . \
        -t chromium-with-proxy
