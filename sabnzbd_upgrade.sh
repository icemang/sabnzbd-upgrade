#!/usr/local/bin/bash
############################################################################################################
#
# -- USER ADJUSTABLE VARIABLES --
#
#  SABDIR needs your local SABnzbd directory location
#  SABCONFIGDIR needs your local SABnzbd CONFIG directory location (Sometimes this is the same as SABDIR)

HOST="10.0.0.1"
SABDIR="SABnzbd"
SABDESTDIR="/datapool/systemfiles"
SABCONFIGDIR="/datapool/systemfiles/SABnzbd.Config"

#For Archive - enter 0 for no or 1 for yes (if yes, specify a direct path)
ARCHIVE="0"
ARCHIVEPATH=""

#If you are on the current version but want to force an update, change the below variable to 1
# Note that changing the below variable to 1 WILL force a reinstall everytime the script runs.
START_UPDATE="0"

#
# -- DONE WITH USER INPUT --
############################################################################################################

LOCAL_VERSION=`cat ${SABDESTDIR}/${SABDIR}/PKG-INFO | grep ^Version | awk '{print $2}'`
VERSION=`curl -s http://sabnzbdplus.sourceforge.net/version/latest | head -n1`

if [ "${VERSION}" != "${LOCAL_VERSION}" ]; then
START_UPDATE="1"
fi

if [ "${START_UPDATE}" = "0" ]; then
        echo "You are on the current version of: ${LOCAL_VERSION}"
        echo "No update will be performed"
else
	API_KEY=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^api_key | awk '{print $3}'`
	PORT=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^port | awk '{print $3}' | head -1`
	DIR="SABnzbd-${VERSION}"
	GZ="${DIR}-src.tar.gz"

        cd ${SABDESTDIR}
        echo "New version found! You are on ${LOCAL_VERSION}, upgrading to ${VERSION} now."

	echo "Downloading SABnzbd ${VERSION} (${GZ})"
	curl -s -C - -O "http://freefr.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/${VERSION}/${GZ}"

	# Alternative source: SWITCH (ch)
	# curl -s -C - -O "http://switch.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus/${VERSION}/${GZ}"

	echo "Unpacking ${GZ}"
	tar -xzf ${GZ}
	rm ${GZ}

	echo "Shutting down SABnzbd+"
	curl -s "http://${HOST}:${PORT}/sabnzbd/api?mode=shutdown&apikey=${API_KEY}" >> /dev/null

	echo "Installing new SABnzbd+"
	if [ "${ARCHIVE}" = "0" ]; then
		rm -rf ${SABDIR}
	else
#		DATE=`date +'%Y%m%d-%H%M'`
#		mkdir -p ${ARCHIVEPATH}
#		mv ${SABDIR} ${ARCHIVEPATH}_${DATE}
	fi
	mv ${DIR} ${SABDIR}

	echo "Restarting SABnzdb+"
	python ${SABDIR}/SABnzbd.py -d -f ${SABCONFIGDIR}/sabnzbd.ini >> /dev/null

	# Go back to the previous directory
	cd -
	echo "Upgrade complete !"
fi
