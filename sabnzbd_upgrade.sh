#!/usr/local/bin/bash
############################################################################################################
#
# -- USER ADJUSTABLE VARIABLES --
#
# HOST - Should be set to "localhost" most likely, or a local IP if you prefer.
# SABDESTDIR - This is the parent directory where your SABnzbd will be located.
# SABCONFIGDIR - This is where your SABnzbd config files are located.
HOST="10.0.0.1"
SABDESTDIR="/datapool/systemfiles"
SABCONFIGDIR="/datapool/systemfiles/SABnzbd.Config"

# For archiving old versions - enter 0 for no or 1 for yes (if yes, choose a directory)
ARCHIVE="1"
ARCHIVEDIR="$HOME/sab_archive"

# Custom URL - Only change if update is not working correctly.
#  (Could try "http://switch.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus" as alternate)
SABURL="http://freefr.dl.sourceforge.net/project/sabnzbdplus/sabnzbdplus"

# SABDIR - This is the SABnzbd directory name. I highly recommend leaving the default of "SABnzbd".
SABDIR="SABnzbd"

# If you are on the current version but want to force an update, change the below variable to 1
# Note that changing the below variable to 1 WILL force a reinstall everytime the script runs.
START_UPDATE="0"

#
# -- DONE WITH USER INPUT --
#
############################################################################################################

if [ -f ${SABDESTDIR}/${SABDIR}/PKG-INFO ] && [ -f ${SABCONFIGDIR}/sabnzbd.ini ]; then
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
		if [ -f ${DIR}-src.tar.gz ]; then
			rm "${DIR}-src.tar.gz"
		fi
		echo "Downloading SABnzbd ${VERSION} (${GZ})"
		curl -s -C - -O "${SABURL}/${VERSION}/${GZ}"

		echo "Unpacking ${GZ}"
		tar -xzf ${GZ} && rm ${GZ}

		echo "Shutting down SABnzbd+"
		curl -s "http://${HOST}:${PORT}/sabnzbd/api?mode=shutdown&apikey=${API_KEY}" >> /dev/null

		if [ "${ARCHIVE}" = "0" ]; then
			if [ "${SABDESTDIR}/${SABDIR}" = "${SABCONFIGDIR}" ]; then
				echo "Moving your config files into your new installation."
				mv ${SABCONFIGDIR}/sabnzbd.ini* ${DIR}
				mv ${SABCONFIGDIR}/admin ${DIR}
				mv ${SABCONFIGDIR}/backup ${DIR}
				mv ${SABCONFIGDIR}/logs ${DIR}
				mv ${SABCONFIGDIR}/temp ${DIR}
			fi
			rm -rf ${SABDIR}
		else
			echo "Archiving old SABnzbd+"
			if [ "${SABDESTDIR}/${SABDIR}" = "${SABCONFIGDIR}" ]; then
				echo "This may take a few moments... (creating a copy of your config files for your archive)"
				cp -r ${SABCONFIGDIR}/sabnzbd.ini* ${DIR}
				cp -r ${SABCONFIGDIR}/admin ${DIR}
				cp -r ${SABCONFIGDIR}/backup ${DIR}
				cp -r ${SABCONFIGDIR}/logs ${DIR}
				cp -r ${SABCONFIGDIR}/temp ${DIR}
			fi
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
else
	echo "There is an error with the variables chosen."
	echo "Currently - I am looking here for your SAB installation: \"${SABDESTDIR}/${SABDIR}\""
	echo "I am also looking here for your SAB configuration files: \"${SABCONFIGDIR}\""
	echo "Please edit the variables at the top of the script and try again."
fi
