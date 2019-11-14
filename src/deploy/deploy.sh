#!/usr/bin/env bash

USAGE="borndeploy <SOURCE_PATH> <TARGET_SERVER> <TARGET_PATH> <USERNAME> <PASSWORD>"

SOURCE_PATH=$1
TARGET_SERVER=$2
TARGET_PATH=$3
USERNAME=$4
PASSWORD=$5

if [[ -z ${SOURCE_PATH+x} ]]; then echo ${USAGE}; fi
if [[ -z ${TARGET_SERVER+x} ]]; then echo ${USAGE}; fi
if [[ -z ${TARGET_PATH+x} ]]; then echo ${USAGE}; fi

if [[ -z ${USERNAME+x} ]]; then echo ${USAGE}; fi
if [[ -z ${PASSWORD+x} ]]; then echo ${USAGE}; fi

sshpass -p "$PASSWORD" scp -r ${SOURCE_PATH} ${USERNAME}@${TARGET_SERVER}:${TARGET_PATH}
