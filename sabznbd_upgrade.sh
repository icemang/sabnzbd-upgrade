#!/bin/bash

cd ~/bin

API_KEY=`cat SABnzbd/sabnzbd.ini | grep ^api_key    | awk '{print $3}'`
PORT=`  cat SABnzbd/sabnzbd.ini | grep ^https_port | awk '{print $3}'`
VERSION=`curl -s http://sabnzbdplus.sourceforge.net/version/latest | head -n1`
DIR="SABnzbd-${VERSION}"
GZ="${DIR}-src.tar.gz"
DATE=`date +'%Y%m%d-%H%M'`

echo "Downloading SABnzbd ${VERSION} (${GZ})"
curl -s -C - -O "http://freefr.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/${VERSION}/${GZ}"

# Alternative source: SWITCH (ch)
# curl -s -C - -O "http://switch.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/0.7.3/SABnzbd-0.7.3-src.tar.gz"

echo "Unpacking ${GZ}"
tar -xzf ${GZ}
rm ${GZ}

echo "Shutting down SABnzbd+"
curl -s "http://localhost:${PORT}/sabnzbd/api?mode=shutdown&apikey=${API_KEY}" >> /dev/null

echo "Installing new SABnzbd+"
cp SABnzbd/sabnzbd.ini ${DIR}/sabnzbd.ini
mkdir -p ~/archives/
mv SABnzbd ~/archives/SABnzbd_${DATE}
mv ${DIR} SABnzbd

echo "Restarting SABnzdb+"
python SABnzbd/SABnzbd.py -d

# Go back to the previous directory 
echo "Upgrade complete !"

cd -
