#!/usr/bin/env bash
TARGET=$1
TARGET=$(realpath $1)
cd ${TARGET}
ls -l ${TARGET}
