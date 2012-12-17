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
ARCHIVE="0"
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
		if [ "${SABDESTDIR}/${SABDIR}" = "${SABCONFIGDIR}" ]; then
			# Need Temp, Admin, Cache, Log and .nzb backup folder locations as specified in sabnzbd.ini
			# Only applies if sab install and sab config folders are equal.
			FOL_TEMP=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^download_dir | awk '{print $3}'`
			FOL_ADMIN=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^admin_dir | awk '{print $3}'`
			FOL_LOG=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^log_dir | awk '{print $3}'`
			FOL_NZB=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^nzb_backup_dir | awk '{print $3}'`
			FOL_CACHE=`cat ${SABCONFIGDIR}/sabnzbd.ini | grep ^cache_dir | awk '{print $3}'`
		fi
		DIR="SABnzbd-${VERSION}"
		GZ="${DIR}-src.tar.gz"
		if [ -f ${DIR}-src.tar.gz ]; then
			rm "${DIR}-src.tar.gz"
		fi
		echo "Downloading and unpacking SABnzbd ${VERSION} (${GZ})"
		curl -s -C - -O "${SABURL}/${VERSION}/${GZ}"
		tar -xzf ${GZ} && rm ${GZ}

		echo "Shutting down SABnzbd+"
		curl -s "http://${HOST}:${PORT}/sabnzbd/api?mode=shutdown&apikey=${API_KEY}" >> /dev/null

		if [ "${ARCHIVE}" = "0" ]; then
			if [ "${SABDESTDIR}/${SABDIR}" = "${SABCONFIGDIR}" ]; then
				echo "Moving your config files into your new installation."
				mv ${SABCONFIGDIR}/sabnzbd.ini* ${DIR}
				mv ${FOL_TEMP} ${DIR}
				mv ${FOL_ADMIN} ${DIR}
				mv ${FOL_LOG} ${DIR}
				mv ${FOL_NZB} ${DIR}
				mv ${FOL_CACHE} ${DIR}
			fi
			rm -rf ${SABDIR}
		else
			echo "Archiving old SABnzbd+"
			if [ "${SABDESTDIR}/${SABDIR}" = "${SABCONFIGDIR}" ]; then
				echo "This may take a few moments... (creating a copy of your config files for your archive)"
				cp -r ${SABCONFIGDIR}/sabnzbd.ini* ${DIR}
                                cp -r ${FOL_TEMP} ${DIR}
                                cp -r ${FOL_ADMIN} ${DIR}
                                cp -r ${FOL_LOG} ${DIR}
                                cp -r ${FOL_NZB} ${DIR}
                                cp -r ${FOL_CACHE} ${DIR}
			fi
			mkdir -p ${ARCHIVEDIR}
			mv ${SABDIR} ${ARCHIVEDIR}/${SABDIR}_${LOCAL_VERSION}_`date +'%Y%m%d-%H%M'`
		fi
		echo "Installing and restarting new SABnzbd+"
		mv ${DIR} ${SABDIR}
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
