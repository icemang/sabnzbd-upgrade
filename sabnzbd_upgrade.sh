#!/usr/local/bin/bash
############################################################################################################
#
# -- USER ADJUSTABLE VARIABLES --
#

#HOST - Should be set to "localhost" most likely, or a local IP if you prefer.
#SABDIR - This is the SABnzbd directory name. I recommend leaving the default of "SABnzbd".
#SABDESTDIR - This is the parent directory where your SABnzbd will be located.
#SABCONFIGDIR - This is where your SABnzbd config files are located.
# Please note that for this script - your config folder must be separate from your main sab folder.

HOST="10.0.0.1"
SABDIR="SABnzbd"
SABDESTDIR="/datapool/systemfiles"
SABCONFIGDIR="/datapool/systemfiles/SABnzbd.Config"

#Custom URL (Could try "http://switch.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus" as alternate)
SABURL="http://freefr.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus"

#For archiving old versions - enter 0 for no or 1 for yes (if yes, choose a directory)
ARCHIVE="1"
ARCHIVEDIR="$HOME/sab_archive"

#If you are on the current version but want to force an update, change the below variable to 1
# Note that changing the below variable to 1 WILL force a reinstall everytime the script runs.
START_UPDATE="0"

#
# -- DONE WITH USER INPUT --
#
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
	cd ${SABDESTDIR}
	echo "New version found! You are on ${LOCAL_VERSION}, upgrading to ${VERSION} now."

	API_KEY=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^api_key | awk '{print $3}'`
	PORT=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^port | awk '{print $3}' | head -1`
	DIR="SABnzbd-${VERSION}"
	GZ="${DIR}-src.tar.gz"

	echo "Downloading SABnzbd ${VERSION} (${GZ})"
	curl -s -C - -O "${SABURL}/${VERSION}/${GZ}"

	echo "Unpacking ${GZ}"
	tar -xzf ${GZ} && rm ${GZ}

	echo "Shutting down SABnzbd+"
	curl -s "http://${HOST}:${PORT}/sabnzbd/api?mode=shutdown&apikey=${API_KEY}" >> /dev/null

	if [ "${ARCHIVE}" = "0" ]; then
		rm -rf ${SABDIR}
	else
		echo "Archiving old SABnzbd+"
		mkdir -p ${ARCHIVEDIR}
		mv ${SABDIR} ${ARCHIVEDIR}/${SABDIR}_${LOCAL_VERSION}_`date +'%Y%m%d-%H%M'`
	fi
	echo "Installing new SABnzbd+"
	mv ${DIR} ${SABDIR}

	echo "Restarting SABnzdb+"
	python ${SABDIR}/SABnzbd.py -d -f ${SABCONFIGDIR}/sabnzbd.ini >> /dev/null

	# Go back to the previous directory
	cd -
	echo "Upgrade complete !"
fi
