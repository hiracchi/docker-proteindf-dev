#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os.path
import logging
import logging.config
logger = logging.getLogger(__name__)

import os
import re

PARSE_ITEMS=[
    r"^CMAKE",
    r"MPI",
    r"HDF5_",
    r"BLAS_LIBRARIES",
    r"LAPACK_LIBRARIES",
    r"SCALAPACK_LIBRARIES",
    r"EIGEN3_INCLUDE_DIR",
    r"NUMPROC",
    r"USE_"
    ]

def cmake_args():
    answer = ""

    re_parses = []
    for i in PARSE_ITEMS:
        re_parses.append(re.compile(i))

    for k,v in os.environ.items():
        for re_obj in re_parses:
            match_ob = re_obj.match(k)
            if match_ob:
                answer += '-D{key}="{value}" '.format(key=k, value=v)

    return answer


def main():
    print(cmake_args())


if __name__ == '__main__':
    if os.path.exists("config.ini"):
        logging.config.fileConfig("config.ini",
                                  disable_existing_loggers=False)
    main()
