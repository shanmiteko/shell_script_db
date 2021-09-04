#!/usr/bin/bash

sudo cp bootstart.service /etc/systemd/system/
systemctl start bootstart.service
systemctl enable bootstart.service
