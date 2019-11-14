#!/usr/bin/env bash

URL="http://www.jibble.org/files/WebServerLite.jar"
DIR="$(dirname "$(readlink -f "$0")")"

if [[ ! -f WebServerLite.jar ]]; then
    echo "WebServerLite is not available, downloading it from $URL"
    wget ${URL} -O "$DIR/WebServerLite.jar"
fi

if [[ -z $1 ]]; then echo "Usage: webs <dir> <port> | webs <port>"; exit; fi

ISPORT='^[0-9]+$'
if ! [[ $1 =~ $ISPORT ]] ; then
        if [[ -z $2 ]]; then
                 echo "Usage: webs <dir> <port>";
                exit;
        fi
	TARGET_PATH=$1
	TARGET_PORT=$2
else
        TARGET_PATH="./"
        TARGET_PORT=$1
fi

TARGET_PATH=$(realpath ${TARGET_PATH})


echo "Serving $TARGET_PATH under http://localhost:$TARGET_PORT"
java -jar ${DIR}/WebServerLite.jar "$TARGET_PATH" "$TARGET_PORT"

