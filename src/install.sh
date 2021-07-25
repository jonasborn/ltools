#!/usr/bin/env bash
TARGET_PATH="/opt/born"
TARGET_SUBPATH="/opt/born/ltools"

sudo mkdir -p ${TARGET_SUBPATH}

sudo mv ./cdl ${TARGET_SUBPATH}/cdl
sudo mv ./deploy ${TARGET_SUBPATH}/deploy
sudo mv ./l ${TARGET_SUBPATH}/l
sudo mv ./webs ${TARGET_SUBPATH}/webs
sudo mv ./raf ${TARGET_SUBPATH}/raf

sudo chown ${USER} ${TARGET_PATH} -R
sudo chown ${USER} ${TARGET_SUBPATH} -R

sudo chmod +x ${TARGET_SUBPATH}/cdl/cdl.sh
sudo chmod +x ${TARGET_SUBPATH}/deploy/deploy.sh
sudo chmod +x ${TARGET_SUBPATH}/l/l.sh
sudo chmod +x ${TARGET_SUBPATH}/webs/webs.sh
sudo chmod +x ${TARGET_SUBPATH}/raf/raf.sh

sudo ln -s ${TARGET_SUBPATH}/cdl/cdl.sh /usr/local/bin/cdl
sudo ln -s ${TARGET_SUBPATH}/deploy/deploy.sh /usr/local/bin/deploy
sudo ln -s ${TARGET_SUBPATH}/l/l.sh /usr/local/bin/l
sudo ln -s ${TARGET_SUBPATH}/webs/webs.sh /usr/local/bin/webs
sudo ln -s ${TARGET_SUBPATH}/webs/raf.sh /usr/local/bin/raf
