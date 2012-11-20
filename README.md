# SABnzbd+ automatic upgrade script

SABnzbd+ is an awesome open-source project, but it lacks an automatic update mechanism.
On Windows or OSX it could be an auto-update executable, but if you run it from the source,
you  have to cook a script by yourself. That's what I did.

## Usage

This script supposes :

* you have SABnzdb+ running with https support and installed in a directory that you choose
* you have SABnzdb+ running with its own config directory that you choose - this helps retain history, etc.
* you store the previous SABnzdb+ versions in "~/archives/"

To upgrade to the latest version, just paste that on your server :

`curl -fsSL https://raw.github.com/icemang/sabnzbd-upgrade/master/sabnzbd_upgrade.sh | sh`

Or download the shell script and run it :

`./sabnzbd_upgrade.sh`

## Thanks
Thanks goes out to https://github.com/czj for the good start that I based this on.
