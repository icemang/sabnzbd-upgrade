#!/bin/bash

cd ~/bin

API_KEY=`cat SABnzbd/sabnzbd.ini | grep ^api_key    | awk '{print $3}'`
PORT=`   cat SABnzbd/sabnzbd.ini | grep ^https_port | awk '{print $3}'`
VERSION=`curl -s http://sabnzbdplus.sourceforge.net/version/latest | head -n1`
VERSION=${VERSION%?}
DIR="SABnzbd-${VERSION}"
GZ="${DIR}-src.tar.gz"
DATE=`date +'%Y%m%d-%H%M'`

echo "Downloading SABnzbd ${VERSION} (${GZ})"
curl -s -C - -O "http://freefr.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/sabnzbd-${VERSION}/${GZ}"

echo "Unpacking ${GZ}"
tar -xzf ${GZ}
rm ${GZ}

echo "Shutting down SABnzbd+"
curl -s "http://localhost:${PORT}/sabnzbd/api?mode=shutdown&apikey=${APIKEY}" >> /dev/null

echo "Installing new SABnzbd+"
cp SABnzbd/sabnzbd.ini ${DIR}/sabnzbd.ini
mv SABnzbd ~/archives/SABnzbd_${DATE}
mv ${DIR} SABnzbd

echo "Restarting SABnzdb+"
python SABnzbd/SABnzbd.py -d

# Go back to the previous directory 
echo "Upgrade complete !"

cd -
