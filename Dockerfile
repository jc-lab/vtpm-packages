ARG BASE_IMAGE
FROM ${BASE_IMAGE}
MAINTAINER Joseph Lee <joseph@jc-lab.net>

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y && \
    apt-get install -y \
    bash curl wget gnupg2 \
    build-essential \
    automake expect gnutls-bin libgnutls28-dev git gawk m4 socat fuse libfuse-dev tpm-tools libgmp-dev libtool libglib2.0-dev libnspr4-dev libnss3-dev libssl-dev libtasn1-6-dev net-tools libseccomp-dev libjson-glib-dev \
    debhelper dh-exec softhsm2 \
    python3-setuptools python3-pip python3-cryptography python3-twisted

RUN mkdir -p /work && \
    mkdir -p /work/dist

COPY [ "pgp.keys.d", "/work/pgp.keys.d" ]

RUN gpg2 --import /work/pgp.keys.d/*.asc

ARG LIBTPMS_FILENAME=v0.7.7.tar.gz
ARG LIBTPMS_ARCHIVE_URL=https://github.com/stefanberger/libtpms/archive/refs/tags/v0.8.4.tar.gz
ARG LIBTPMS_ASC_URL=https://github.com/stefanberger/libtpms/releases/download/v0.8.4/v0.8.4.tar.gz.asc
ARG LIBTPMS_SHA256=5f8b0ed59d52fe22e7245a0d5909e33a72b4d2dac47ee877ea9ff3c307b2ed19

RUN cd /work && \
    curl -L -o ${LIBTPMS_FILENAME} ${LIBTPMS_ARCHIVE_URL} && \
    curl -L -o ${LIBTPMS_FILENAME}.asc ${LIBTPMS_ASC_URL} && \
    gpg2 --verify ${LIBTPMS_FILENAME}.asc ${LIBTPMS_FILENAME} && \
    echo "${LIBTPMS_SHA256}  ${LIBTPMS_FILENAME}" | tee /dev/stderr | sha256sum -c

ARG SWTPM_FILENAME=swtpm.tar.gz
ARG SWTPM_ARCHIVE_URL=https://github.com/stefanberger/swtpm/archive/refs/tags/v0.6.0.tar.gz
ARG SWTPM_ASC_URL=https://github.com/stefanberger/swtpm/releases/download/v0.6.0/v0.6.0.tar.gz.asc
ARG SWTPM_SHA256=d05098d6879a44f02cb0225290f2edeea083ea9a322f5acf98c7a6ddb5f46d29

RUN cd /work && \
    curl -L -o ${SWTPM_FILENAME} ${SWTPM_ARCHIVE_URL} && \
    curl -L -o ${SWTPM_FILENAME}.asc ${SWTPM_ASC_URL} && \
    gpg2 --verify ${SWTPM_FILENAME}.asc ${SWTPM_FILENAME} && \
    echo "${SWTPM_SHA256}  ${SWTPM_FILENAME}" | tee /dev/stderr | sha256sum -c

COPY [ "build-package.sh", "/opt/build-package.sh" ]
RUN chmod +x /opt/build-package.sh

RUN mkdir -p /work/libtpms && \
    cd /work/libtpms && \
    tar --strip-components 1 -xf /work/${LIBTPMS_FILENAME} && \
    /opt/build-package.sh && \
    find /work -type f -name "libtpms*.deb" -maxdepth 1 | xargs dpkg -i

RUN mkdir -p /work/swtpm && \
    cd /work/swtpm && \
    tar --strip-components 1 -xf /work/${SWTPM_FILENAME} && \
    /opt/build-package.sh

RUN cd /work && \
    sha256sum *.deb

