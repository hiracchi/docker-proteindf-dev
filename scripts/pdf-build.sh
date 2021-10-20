#!/bin/bash
# set -eux
set -o pipefail

CONFIGURE_ONLY=no

if [ "x${MAKE_OPTS}" != x ]; then
    echo "MAKE_OPTS=${MAKE_OPTS}"
else
    echo "no MAKE_OPTS variable."
fi

UNBUFFER=
if [ `which unbuffer` ]; then
    UNBUFFER="unbuffer"
fi

PIP="pip"
if [ `which pip3` ]; then
    PIP="pip3"
fi

# ======================================================================
# FUNCTIONS
# ======================================================================
setup_pytools()
{
    local OPTIONS=""
    if [ x${DEBUG_MODE} = "xON" ]; then
        echo "debug mode on."
        OPTIONS="--editable"
    fi

    ${PIP} install --upgrade --use-feature=in-tree-build --prefix=${PDF_HOME} ${OPTIONS} .
}


# cmake版
build_pdf_cmake()
{
    if [ -d build ]; then
        rm -rf build
    fi
    mkdir build
    cd build

    # cmake setup
    CMAKE_ENV_OPTS=`env2cmake.py`
    eval "cmake -DCMAKE_INSTALL_PREFIX=\"${PDF_HOME}\" ${CMAKE_ENV_OPTS}" .. 2>&1 | tee out.cmake

    if [ "x${CONFIGURE_ONLY}" != "xyes" ]; then
        { ${UNBUFFER} make ${MAKE_OPTS} 2>&1 | tee out.make; } \
            && { ${UNBUFFER} make install 2>&1 | tee out.make_install; } \
            && { ${UNBUFFER} make ARGS="--verbose" test 2>&1 | tee out.make_test; }
    fi
}


build_pdf_configure()
{
    #CONFIGURE_OPT=" \
    #    --enable-debug \
    #    --enable-cppunit
    BASEDIR=`pwd`

    if [ -d autom4te.cache ]; then
        rm -rf autom4te.cache
    fi

    if [ -f bootstrap.sh ]; then
        ./bootstrap.sh
    fi

    ./configure \
        --prefix=${PDF_HOME} \
        ${CONFIGURE_OPT} \
        --enable-parallel \
        --with-blas="${BLAS_LIBRARIES}" \
        --with-lapack="${LAPACK_LIBRARIES}" \
        --with-scalapack="${SCALAPACK_LIBRARIES}" \
        2>&1 | tee out.configure

    if [ "x${CONFIGURE_ONLY}" != "xyes" ]; then
        make -j 3 2>&1 | tee out.make
        make install 2>&1 | tee out.make_install
    fi
}


# ======================================================================
# option
# ======================================================================
declare -a ARGV=()
DEBUG_MODE=OFF

for OPT in "$@"; do
    case "$OPT" in
        '-h'|'--help')
            show_help
            exit 0
            ;;

        '--configure-only')
            CONFIGURE_ONLY=yes
            shift 1
            ;;

        '-d'|'--debug')
            DEBUG_MODE=ON
            CMAKE_BUILD_TYPE="Debug"
            ;;

        '-v'|'--verbose')
            CMAKE_VERBOSE_MAKEFILE="1"
            ;;

        '--'|'-')
            shift 1
            ARGV+=( "$@" )
            break
            ;;
        -*)
            echo "unknown option: ${1}"
            show_help
            exit 1
            ;;
        *)
            if [[ ! -z "$1" ]] && [[ ! "$1" =~ ^-+ ]]; then
                ARGV=("${ARGV[@]}" "$1")
                shift 1
            fi
            ;;
    esac
done
ARGC=${#ARGV[@]}
#echo "ARGC=${ARGC}"
#echo "ARGV[@]=${ARGV[@]}"


# ======================================================================
# MAIN
# ======================================================================
if [ "x${PDF_HOME}" = x ]; then
   echo "environment variable \"PDF_HOME\" is not set. stop."
   exit 1
fi
echo "PDF_HOME=${PDF_HOME}"


if [ -f setup.py ]; then
    echo "build python application ..."
    setup_pytools
elif [ -f CMakeLists.txt ]; then
    echo "build by using CMake ..."
    build_pdf_cmake
elif [ -f bootstrap.sh -o -f configure ]; then
    echo "build by using automake ..."
    build_pdf_configure
else
    echo "cannot find how to build. stop."
    exit 1
fi
