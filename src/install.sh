#!/usr/bin/env bash
TARGET_PATH="/opt/born"
TARGET_SUBPATH="/opt/born/ltools"

echo "Removing old versions of ltools..."

sudo rm -rf ${TARGET_SUBPATH}

sudo unlink /usr/local/bin/cdl
sudo unlink /usr/local/bin/deploy
sudo unlink /usr/local/bin/l
sudo unlink /usr/local/bin/webs
sudo unlink /usr/local/bin/raf

sudo mkdir -p ${TARGET_SUBPATH}

echo "Moving data..."

#sudo mv ./cdl ${TARGET_SUBPATH}/cdl
sudo mv ./deploy ${TARGET_SUBPATH}/deploy
sudo mv ./l ${TARGET_SUBPATH}/l
sudo mv ./webs ${TARGET_SUBPATH}/webs
sudo mv ./raf ${TARGET_SUBPATH}/raf

sudo chown ${USER} ${TARGET_PATH} -R
sudo chown ${USER} ${TARGET_SUBPATH} -R

#sudo chmod +x ${TARGET_SUBPATH}/cdl/cdl.sh
sudo chmod +x ${TARGET_SUBPATH}/deploy/deploy.sh
sudo chmod +x ${TARGET_SUBPATH}/l/l.sh
sudo chmod +x ${TARGET_SUBPATH}/webs/webs.sh
sudo chmod +x ${TARGET_SUBPATH}/raf/raf.sh

echo "Linking..."

#sudo ln -s ${TARGET_SUBPATH}/cdl/cdl.sh /usr/local/bin/cdl
sudo ln -s ${TARGET_SUBPATH}/deploy/deploy.sh /usr/local/bin/deploy
sudo ln -s ${TARGET_SUBPATH}/l/l.sh /usr/local/bin/l
sudo ln -s ${TARGET_SUBPATH}/webs/webs.sh /usr/local/bin/webs
sudo ln -s ${TARGET_SUBPATH}/raf/raf.sh /usr/local/bin/raf

echo "Finished!"
