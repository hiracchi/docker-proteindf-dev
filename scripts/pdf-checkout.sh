#!/bin/bash

# set -x
BRANCH="master"
BASEDIR=`pwd`

ORIGIN_PROTEINDF="https://github.com/ProteinDF/ProteinDF.git"
ORIGIN_PROTEINDF_PYTOOLS="https://github.com/ProteinDF/ProteinDF_pytools.git"
ORIGIN_PROTEINDF_BRIDGE="https://github.com/ProteinDF/ProteinDF_bridge.git"
ORIGIN_QCLOBOT="https://github.com/ProteinDF/QCLObot.git"
ORIGIN_PROTEINDF_USERMAN="https://github.com/ProteinDF/ProteinDF_userman.git"
ORIGIN_PROTEINDF_TEST="https://github.com/ProteinDF/ProteinDF_test.git"

GITHUB_PROTEINDF="git@github.com:ProteinDF/ProteinDF.git"
GITHUB_PROTEINDF_PYTOOLS="git@github.com:ProteinDF/ProteinDF_pytools.git"
GITHUB_PROTEINDF_BRIDGE="git@github.com:ProteinDF/ProteinDF_bridge.git"
GITHUB_QCLOBOT="git@github.com:ProteinDF/QCLObot.git"
GITHUB_PROTEINDF_USERMAN="git@github.com:ProteinDF/ProteinDF_userman.git"
GITHUB_PROTEINDF_TEST="git@github.com:ProteinDF/ProteinDF_test.git"

BITBUCKET_PROTEINDF="git@bitbucket.org:hiracchi/proteindf.git"
BITBUCKET_PROTEINDF_PYTOOLS="git@bitbucket.org:hiracchi/proteindf_pytools.git"
BITBUCKET_PROTEINDF_BRIDGE="git@bitbucket.org:hiracchi/proteindf_bridge.git"
BITBUCKET_QCLOBOT="git@bitbucket.org:hiracchi/qclobot.git"
BITBUCKET_PROTEINDF_USERMAN="git@bitbucket.org:hiracchi/proteindf_userman.git"
BITBUCKET_PROTEINDF_TEST="git@bitbucket.org:hiracchi/proteindf_test.git"

LOCAL_PROTEINDF="${HOME}/work/dev/MyRepos/ProteinDF"
LOCAL_PROTEINDF_PYTOOLS="${HOME}/work/dev/MyRepos/ProteinDF_pytools"
LOCAL_PROTEINDF_BRIDGE="${HOME}/work/dev/MyRepos/ProteinDF_bridge"
LOCAL_QCLOBOT="${HOME}/work/dev/MyRepos/QCLObot"
LOCAL_PROTEINDF_USERMAN="${HOME}/work/dev/MyRepos/ProteinDF_userman"
LOCAL_PROTEINDF_TEST="${HOME}/work/dev/MyRepos/ProteinDF_test"

show_help()
{
    echo "get the sources of the ProteinDF system"
    echo "${0} [ITEM]..."
    echo ""
    echo "ITEM: ProteinDF ProteinDF_bridge ProteinDF_pytools QCLObot ProteinDF_test"
    echo
    echo "OPTIONS:"
    echo "--work <DIR>         dest dir."
    echo "--branch <BRANCH>    clone the specified branch."
    echo "-d                   setting for developer"
}


clone()
{
    HOST=${1}
    NAME=${2}
    BRANCH=${3}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    HOST_UPPERCASE=`echo ${HOST} | tr '[a-z]' '[A-Z]'`
    HOST_LOWERCASE=`echo ${HOST} | tr '[A-Z]' '[a-z]'`
    REPOS=`eval echo '$'${HOST_UPPERCASE}_${NAME_UPPERCASE}`

    if [ x"${BRANCH}" = x ]; then
        BRANCH="master"
    fi

    # clone all for develop env.
    git clone --origin ${HOST_LOWERCASE} --branch ${BRANCH} ${REPOS} ${NAME}
}


init_gitflow()
{
    NAME=${1}

    (cd ${NAME};
     git fetch --all --prune;
     git flow init -df;
    )
}


add_remote()
{
    HOST=${1}
    NAME=${2}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    HOST_UPPERCASE=`echo ${HOST} | tr '[a-z]' '[A-Z]'`
    REPOS=`eval echo '$'${HOST_UPPERCASE}_${NAME_UPPERCASE}`

    (cd ${NAME}; \
     git remote add ${HOST} ${REPOS}; \
     git fetch --all --prune; \
    )
}


checkout_branch()
{
    HOST=${1}
    NAME=${2}
    BRANCH=${3}

    NAME_UPPERCASE=`echo ${NAME} | tr '[a-z]' '[A-Z]'`
    HOST_UPPERCASE=`echo ${HOST} | tr '[a-z]' '[A-Z]'`
    REPOS=`eval echo '$'${HOST_UPPERCASE}_${NAME_UPPERCASE}`

    (cd ${NAME}; \
     git checkout -b ${BRANCH} ${HOST}/${BRANCH}; 
    )
}


# ======================================================================
# option
# ======================================================================
DEVELOP_MODE=no

declare -a ARGV=()

for OPT in "$@"; do
    case "$OPT" in
        '-h'|'--help')
            show_help
            exit 0
            ;;

        '-w'|'--work')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            WORKDIR="$2"
            shift 2
            ;;

        '--branch')
            if [[ -z "${2}" ]] || [[ "${2}" =~ ^-+ ]]; then
                echo "$PROGNAME: option requires an argument -- ${1}" 1>&2
                exit 1
            fi
            BRANCH="$2"
            shift 2
            ;;

        '-d'|'--develop')
            DEVELOP_MODE=yes
            shift 1
            ;;

        '-l'|'--local')
            LOCAL=yes
            shift 1
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


# MAIN -----------------------------------------------------------------
if [ ${ARGC} -eq 0 ]; then
    show_help
    exit 1
fi

if [ -n "${WORKDIR}" ]; then
    echo "WORKDIR=${WORKDIR}"
    if [ -d "${WORKDIR}" ]; then
        cd "${WORKDIR}"
    fi
fi

for TARGET in ${ARGV[@]}; do
    echo ">>>> ${TARGET}"
    if [ x"${DEVELOP_MODE}" == xyes ]; then
        clone github ${TARGET} ${BRANCH}
        checkout_branch github ${TARGET} develop
        init_gitflow ${TARGET}
        add_remote bitbucket ${TARGET}
    elif [ x${LOCAL} == xyes ]; then
        clone local ${TARGET} ${BRANCH}
	checkout_branch local ${TARGET} develop
	init_gitflow ${TARGET}
    else
        clone origin ${TARGET} ${BRANCH}
    fi
    echo "Done."
done
