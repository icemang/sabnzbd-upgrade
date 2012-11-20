#!/bin/bash
############################################################################################################
#
# -- USER ADJUSTABLE VARIABLES --
#
#  SABDIR needs your local SABnzbd directory location
#  SABCONFIGDIR needs your local SABnzbd CONFIG directory location (Sometimes this is the same as SABDIR)

HOST="localhost"
SABDIR=/datapool/systemfiles/SABnzbd
SABCONFIGDIR=/datapool/systemfiles/SABnzbd.Config
TEMPDIR="~/sabupgradetemp907821034"

#
# -- DONE WITH USER INPUT --
############################################################################################################

API_KEY=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^api_key | awk '{print $3}'`
PORT=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^https_port | awk '{print $3}'`
VERSION=`curl -s http://sabnzbdplus.sourceforge.net/version/latest | head -n1`

#added this to work on checking local version
LOCAL_VERSION=`cat ${SABDIR}/PKG-INFO | grep ^version | awk '{print $3}'`

DIR="SABnzbd-${VERSION}"
GZ="${DIR}-src.tar.gz"
DATE=`date +'%Y%m%d-%H%M'`

mkdir ${TEMPDIR} && cd ${TEMPDIR}

echo "Downloading SABnzbd ${VERSION} (${GZ})"
curl -s -C - -O "http://freefr.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/${VERSION}/${GZ}" | tar -xzf -

# Alternative source: SWITCH (ch)
# curl -s -C - -O "http://switch.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/0.7.3/SABnzbd-0.7.3-src.tar.gz" | tar -xzf -

echo "Shutting down SABnzbd+"
curl -s "http://${HOST}:${PORT}/sabnzbd/api?mode=shutdown&apikey=${API_KEY}" >> /dev/null

echo "Installing new SABnzbd+"
mkdir -p ~/archives/
mv ${SABDIR} ~/archives/SABnzbd_${DATE}
mv ${DIR} ${SABDIR}

echo "Restarting SABnzdb+"
python ${SABDIR}/SABnzbd.py -d -f ${SABCONFIGDIR}/sabnzbd.ini > /dev/null

# Go back to the previous directory 
cd -
echo "Upgrade complete !"
