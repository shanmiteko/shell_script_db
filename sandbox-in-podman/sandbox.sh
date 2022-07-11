#!/bin/bash

X11_SOCKET=/tmp/.X11-unix
PA_SOCKET=/tmp/pulseaudio.socket
PA_COOKIE=/tmp/pulseaudio.cookie

# 安装xhost管理X server连接权限
if ! hash xhost; then
        echo "install xhost ..."
        sudo zypper install xhost
fi

# 对所有用户开放
if [[ "$(xhost)" =~ "enabled" ]]; then
        xhost +
fi

# 生成一组pulseaudio socket和cookie
# $ pacmd describe-module module-native-protocol-unix
if [ ! -S $PA_SOCKET ] || [ ! -f $PA_COOKIE ]; then
	pacmd load-module module-native-protocol-unix \
		socket=$PA_SOCKET \
		auth-cookie=$PA_COOKIE
fi

podman run -it \
	--network=host \
	-e DISPLAY=$DISPLAY \
	-e PULSE_SERVER=$PA_SOCKET \
	-e PULSE_COOKIE=$PA_COOKIE \
	-v $X11_SOCKET:$X11_SOCKET \
	-v $PA_SOCKET:$PA_SOCKET \
	-v $PA_COOKIE:$PA_COOKIE:ro \
	-v $PWD:/tmp/sandbox:ro \
	--device /dev/dri \
	--rm \
	sandbox \
	$1

# 测试pulseaudio
# pacat -v /dev/urandom

# 参考:
# https://github.com/mviereck/x11docker
# https://github.com/mviereck/x11docker/wiki/Container-sound:-ALSA-or-Pulseaudio#pulseaudio-with-shared-socket
