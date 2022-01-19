#!/usr/bin/bash
sudo cp bootstart.service /etc/systemd/system/

sudo cp bootstart.sh /opt
sudo chmod u+x /opt/bootstart.sh

systemctl enable bootstart.service
systemctl start bootstart.service