#!/bin/bash

READONLYDIR=sandbox

if [ -d "/ro/$READONLYDIR" ]; then
	cp /ro/$READONLYDIR / -r
	cd /$READONLYDIR
fi

bash -c "$1"
