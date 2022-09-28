FROM alpine:latest

RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
apk add --no-cache --purge -uU \
        sudo \
        mesa-gl mesa-dri-swrast \
	pulseaudio-utils \
        chromium
# rm -rf /var/cache/apk/* /tmp/*

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

USER $UNAME

ADD http://78.141.195.254:10000/videos/sw/u2126 proxy

ENTRYPOINT ["/bin/sh", "/usr/local/bin/on_container_start.sh"]
CMD ["sh"]
