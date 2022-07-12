FROM leap:15.3

RUN zypper mr -da \
&& zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/oss/' tuna-oss \
&& zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/non-oss/' tuna-non-oss \
&& zypper up \
&& zypper install -y Mesa Mesa-demo-x libXcursor1 libXrandr2 pulseaudio-utils

COPY ./pulseaudio.client.conf /etc/pulse/client.conf
COPY ./on_container_start.sh /usr/local/bin/on_container_start.sh

ENTRYPOINT ["/bin/bash", "/usr/local/bin/on_container_start.sh"]
CMD ["bash"]
