#!/bin/bash

X11_SOCKET=/tmp/.X11-unix
PA_SOCKET=/tmp/pulseaudio.socket

# 安装xhost管理X server连接权限
if ! hash xhost; then
        echo "install xhost ..."
        sudo zypper install xhost
fi

# 对所有用户开放
if [[ "$(xhost)" =~ "enabled" ]]; then
        xhost +
fi

# 生成pulseaudio socket
# $ pacmd describe-module module-native-protocol-unix
if [ ! -S $PA_SOCKET ] || [ ! -f $PA_COOKIE ]; then
	pacmd load-module module-native-protocol-unix \
		socket=$PA_SOCKET \
		auth-cookie-enabled=0
fi

podman run -it \
	--network=host \
	-e DISPLAY=$DISPLAY \
	-v $X11_SOCKET:$X11_SOCKET:ro \
	-v $PA_SOCKET:$PA_SOCKET:ro \
	-v $PWD:/ro/sandbox:ro \
	--device /dev/dri \
	--device /dev/vga_arbiter \
	--rm \
	sandbox \
	"$1"

# 测试X server
# sandbox "glxgears -info"

# 测试pulseaudio
# sandbox "pacat -v /dev/urandom"

# 参考:
# https://github.com/mviereck/x11docker
# https://github.com/mviereck/x11docker/wiki/Container-sound:-ALSA-or-Pulseaudio#pulseaudio-with-shared-socket
