# SABnzbd+ automatic upgrade script

SABnzbd+ is an awesome open-source project, but it lacks an automatic update mechanism.
On Windows or OSX it could be an auto-update executable, but if you run it from the source,
you have to cook a script by yourself. I tweaked the script from czj a bit to add some variables.

## Usage

This script supposes :

* you are comfortable adjusting some variables at the top of the script once downloaded.
* you have SABnzdb+ running and installed in a directory that you know and will add to the script.
* you have SABnzdb+ running with its own config directory that you know and will add to the script. (This helps retain history, etc.)
* you would like the option to archive old versions and choose a directory for archives that you can add to the script.

To upgrade to the latest version download the shell script, adjust the variables at the top and run it:

`./sabnzbd_upgrade.sh`

## Thanks
Thanks goes out to https://github.com/czj for the good start that I based this on.
