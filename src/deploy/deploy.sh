#!/usr/bin/env bash

USAGE="deploy <SOURCE_PATH> <TARGET_SERVER> <TARGET_PATH> <USERNAME> <PASSWORD>"

SOURCE_PATH=$1
TARGET_SERVER=$2
TARGET_PATH=$3
USERNAME=$4
PASSWORD=$5

if [[ -z ${SOURCE_PATH} ]]; then echo ${USAGE}; exit; fi
if [[ -z ${TARGET_SERVER} ]]; then echo ${USAGE}; exit; fi
if [[ -z ${TARGET_PATH} ]]; then echo ${USAGE}; exit; fi

if [[ -z ${USERNAME} ]]; then echo ${USAGE}; exit; fi
if [[ -z ${PASSWORD} ]]; then echo ${USAGE}; exit; fi

sshpass -p "$PASSWORD" scp -r ${SOURCE_PATH} ${USERNAME}@${TARGET_SERVER}:${TARGET_PATH}
