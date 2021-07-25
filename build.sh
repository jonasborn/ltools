#!/usr/bin/env bash
URL="https://github.com/megastep/makeself/releases/download/release-2.4.0/makeself-2.4.0.run"
DIR="$(dirname "$(readlink -f "$0")")"

TARGET_PATH="./makeself*"
TARGET_PATH=$(realpath ${TARGET_PATH})


if [[ ! -d ${TARGET_PATH} ]]; then
    echo "makseself.sh is not available, downloading it from $URL"
    wget ${URL} -O "$DIR/makeself.sh"
    chmod +x "makeself.sh"
    ./makeself.sh
    rm ./makeself.sh
fi

./makeself*/makeself.sh "$DIR/src" "ltools.sh" "born's linux tools" "./install.sh"

rm -rf ./makeself*
