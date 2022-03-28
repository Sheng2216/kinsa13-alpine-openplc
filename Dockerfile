ARG BASE_IMAGE="alpine:3.15"
FROM $BASE_IMAGE as buildenv

RUN apk add --no-cache autoconf automake bison cmake flex g++ git \
        make libtool linux-headers pkgconf python3 py3-flask \
        py3-flask-login py3-pip py3-pyserial sqlite && \
    rm -f /var/cache/apk/* && \
    pip3 install pymodbus && \
    git clone -b development --depth=1 https://github.com/kinsamanka/OpenPLC_v3.git /openplc && \
    cd openplc && \
    cmake -DCMAKE_INSTALL_PREFIX=/opt/openplc -DOPLC_ALL=OFF -DOPLC_ALL_SUPPORTING_TOOLS=ON \
          -DOPLC_ALL_SUPPORTING_LIBRARIES=ON -DOPLC_MUSL=ON -B build . && \
    make  -j$(nproc) -C build install

FROM $BASE_IMAGE

ARG BUILD_DATE
ARG GIT_REV
ARG DOCKER_TAG="0.1"

LABEL \
    org.opencontainers.image.title="alpine-openplc" \
    org.opencontainers.image.description="OpenPLC v3 image running on Alpine Linux" \
    org.opencontainers.image.authors="GP Orcullo<kinsamanka@gmail.com>" \
    org.opencontainers.image.version=$DOCKER_TAG \
    org.opencontainers.image.url="https://hub.docker.com/repository/docker/kinsamanka/alpine-openplc" \
    org.opencontainers.image.source="https://gitlab.com/kinsa13/tango/Docker/alpine-openplc" \
    org.opencontainers.image.revision=$GIT_REV \
    org.opencontainers.image.created=$BUILD_DATE


COPY --from=buildenv /opt/openplc /opt/openplc

WORKDIR /opt/openplc/webserver

RUN apk add --no-cache g++ libcap python3 py3-flask \
        py3-flask-login py3-pip py3-pyserial sqlite && \
    rm -f /var/cache/apk/* && \
    pip3 install pymodbus && \
    setcap 'cap_net_bind_service=+ep' /usr/bin/python3.9 && \
    adduser -h /home/openplc -s /bin/ash -D openplc && \
    chown openplc:openplc -R /opt/openplc && \
    su -c "/opt/openplc/scripts/compile_program.sh blank_program.st" openplc && \
    rm -rf /tmp/*

USER openplc

EXPOSE 502 8080 20000 44818

CMD ["python3.9", "webserver.py"]
