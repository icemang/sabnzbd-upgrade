# SABnzbd+ automatic upgrade script

SABnzbd+ is an awesome open-source project, but it lacks an automatic update mechanism.
On Windows or OSX it could be an auto-update executable, but if you run it from the source,
you  have to cook a script by yourself. That's what I did.

## Usage

This script supposes :

* you have SABnzdb+ running with https support and installed in a directory that you choose
* you have SABnzdb+ running with its own config directory that you choose - this helps retain history, etc.
* you store the previous SABnzdb+ versions in "~/archives/"

To upgrade to the latest version download the shell script, adjust variables at the top and run it :

`./sabnzbd_upgrade.sh`

## Thanks
Thanks goes out to https://github.com/czj for the good start that I based this on.
