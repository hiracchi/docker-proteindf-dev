#!/bin/bash

BUILDER="/usr/local/bin/pdf-build.sh"

printenv
echo "WORKDIR=${PWD}"
echo "PDF_HOME=${PDF_HOME}"
echo

PACKAGES="ProteinDF ProteinDF_bridge ProteinDF_pytools QCLObot"

for package in ${PACKAGES}; do
    cd ${WORKDIR}
    echo "build ${package}"
    if [ -d ${package} ]; then
        cd ${package}
        ${BUILDER}
    fi
done
