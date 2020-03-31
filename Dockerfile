FROM hiracchi/ubuntu-ja:18.04.2

ARG BUILD_DATE
ARG VCS_REF
ARG VERSION
LABEL org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-url="https://github.com/hiracchi/docker-pdf-builder" \
    org.label-schema.version=$VERSION \
    maintainer="Toshiyuki Hirano <hiracchi@gmail.com>"

ARG GROUP_NAME=docker
ARG USER_NAME=docker
ARG USER_ID=1000
ARG GROUP_ID=1000

ARG PDF_HOME="/opt/ProteinDF"
ARG WORKDIR="/work"


# -----------------------------------------------------------------------------
# packages
# -----------------------------------------------------------------------------
RUN set -x && \
    apt-get update && \
    apt-get install -y \
    curl ca-certificates \
    vim \
    build-essential gfortran \
    pkg-config \
    git automake autoconf libtool cmake \
    libopenblas-base libopenblas-dev \
    libscalapack-openmpi-dev \
    openmpi-bin openmpi-common \
    \
    libeigen3-dev \
    \
    opencl-headers libclc-dev mesa-opencl-icd clinfo \
    \
    libboost-all-dev \
    hdf5-tools \
    libhdf5-dev \
    libhdf5-openmpi-dev \
    \
    python3-dev python3-pip \
    && \
    apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*


# -----------------------------------------------------------------------------
# pip package
# -----------------------------------------------------------------------------
RUN set -x && \
    pip3 install --no-cache-dir \
    jupyter \
    jupyter_contrib_nbextensions \
    jupyter_nbextensions_configurator \
    ipywidgets \
    pytraj \
    nglview


# -----------------------------------------------------------------------------
# viennacl-dev
# -----------------------------------------------------------------------------
WORKDIR /tmp
RUN set -x && \
    curl -L -o ViennaCL-1.7.1.tar.gz "http://sourceforge.net/projects/viennacl/files/1.7.x/ViennaCL-1.7.1.tar.gz/download" && \
    tar zxvf ViennaCL-1.7.1.tar.gz && \
    mv ViennaCL-1.7.1/viennacl /usr/local/include/ && \
    chown -R root:root /usr/local/include/viennacl && \
    rm -rf ViennaCL-1.7.1


# -----------------------------------------------------------------------------
# google-test
# -----------------------------------------------------------------------------
WORKDIR /tmp
RUN set -x && \
    git clone "https://github.com/google/googletest.git" && \
    mkdir -p /tmp/googletest/build && \
    cd /tmp/googletest/build && \
    cmake .. && \
    make && \
    make install && \
    rm -rf /tmp/googletest


# -----------------------------------------------------------------------------
# entrypoint
# -----------------------------------------------------------------------------
COPY scripts/* /usr/local/bin/

WORKDIR ${WORKDIR}
ENV PDF_HOME="${PDF_HOME}" PATH="${PDF_HOME}/bin:~/.local/bin:${PATH}"
ENV WORKDIR="${WORKDIR}"
VOLUME ${WORKDIR}

USER ${USER_NAME}:${GROUP_NAME}
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["/usr/bin/tail", "-f", "/dev/null"]
# CMD ["/usr/local/bin/run-jupyter.sh"]
