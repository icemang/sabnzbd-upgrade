# SABnzbd+ automatic upgrade script

SABnzbd+ is an awesome open-source project, but it lacks an automatic update mechanism.

One could do use Sparkle on OSX to have it auto-update, but if you run it from the source, you 
have to cook a script by yourself.

## Usage

This script supposes :

* you have SABnzdb+ installed in "~/bin/SABnzdb"
* you store the previous SABnzdb+ versions in "~/archives/"
* you run the server on https

To upgrade to the latest version, just paste that on your server :

`curl -fsSL https://raw.github.com/czj/sabnzbd-upgrade/master/sabznbd_upgrade.sh | sh`

Or download the shell script and run it :

`./sabnzbd_upgrade.sh`
