FROM ghcr.io/hiracchi/docker-ubuntu:latest

ARG PDF_HOME="/opt/ProteinDF"
ARG WORKDIR="/work"

USER root
# -----------------------------------------------------------------------------
# packages
# -----------------------------------------------------------------------------
USER root
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
    python3-numpy \
    python3-scipy \
    python3-pandas \
    python3-matplotlib \
    python3-sklearn \
    python3-yaml \
    python3-msgpack \
    libmsgpack-dev \
    python3-bs4 \
    python3-h5py \
    python3-jinja2 \
    \
    cython3 \
    python3-notebook \
    python3-ipykernel \
    python3-ipywidgets \
    python3-widgetsnbextension \
    && \
    apt-get clean && apt-get autoclean && \
    rm -rf /var/lib/apt/lists/*


# -----------------------------------------------------------------------------
# pip package
# -----------------------------------------------------------------------------
RUN set -x && \
    pip3 install --no-cache-dir \
    nglview

#     pytraj 

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
RUN set -x && \
    chmod +x /usr/local/bin/*.sh

ENV PDF_HOME="${PDF_HOME}" PATH="${PDF_HOME}/bin:~/.local/bin:${PATH}"
ENV WORKDIR="${WORKDIR}"
VOLUME ${WORKDIR}

USER ${USER_NAME}:${GROUP_NAME}
WORKDIR ${WORKDIR}
CMD ["/usr/local/bin/usage.sh"]
