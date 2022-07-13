#!/bin/bash

COMMAND="$1"
MOUNT_DIR=sandbox

if [ -d "/ro/$MOUNT_DIR" ]; then
	cp /ro/$MOUNT_DIR ~ -r
	sudo chown -R $(id -u):$(id -g) ~/$MOUNT_DIR
	cd ~/$MOUNT_DIR
fi

[ -z "$COMMAND" ] && COMMAND=bash
bash -c "$COMMAND"
