FROM leap:15.3

RUN zypper mr -da \
&& zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/oss/' tuna-oss \
&& zypper ar -cfg 'https://mirrors.tuna.tsinghua.edu.cn/opensuse/distribution/leap/$releasever/repo/non-oss/' tuna-non-oss \
&& zypper up \
&& zypper install -y sudo Mesa Mesa-demo-x libXcursor1 libXrandr2 pulseaudio-utils

ARG UID
ARG GID
ENV UNAME anonym
ENV HOME /home/$UNAME

WORKDIR $HOME

RUN echo "${UNAME}:x:${UID}:${GID}:${UNAME} user,,,:${HOME}:/bin/bash" >> /etc/passwd && \
echo "${UNAME}:x:${UID}:" >> /etc/group && \
echo "${UNAME} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${UNAME} && \
chmod 0440 /etc/sudoers.d/${UNAME} && \
chown -R ${UID}:${GID} $HOME

COPY ./pulseaudio.client.conf /etc/pulse/client.conf
COPY ./on_container_start.sh /usr/local/bin/on_container_start.sh

USER anonym
ENTRYPOINT ["/bin/bash", "/usr/local/bin/on_container_start.sh"]
CMD ["bash"]
