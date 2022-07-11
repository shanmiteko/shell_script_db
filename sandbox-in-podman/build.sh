#!/bin/bash

podman build \
	. \
	-t sandbox
	# --build-arg UID=$(id -u) \
	# --build-arg GID=$(id -g) \
