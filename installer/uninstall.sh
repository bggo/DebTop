#!/bin/bash
###############################################################################
# DebTop Installer
#
# This script installs the DebTop envionment on the Motorola Atrix phone. It
# will also create the appropriate launchers on the WebTop bar to applications
# on the Debian image.
#
# Author: Bruno Gurgel <bruno.gurgel@noroyalties.org>
# License: GPLv3
###############################################################################

echo ""
echo "Looking for a DebTop Instalation."

if [ -d /opt/DebTop ]; then
	echo ""
	echo "DebTop found /opt/DebTop . . . . removing"
	sudo rm -rf opt/DebTop
else
	echo "No DebTop instalation found .... "
fi

echo ""
echo "Fixing tomoyo config."
if [ -a /etc/tomoyo/domain_policy.conf.DebTop.orig ]; then
	echo ""
	echo "Original config found, rewriting . . . "
	sudo mv /etc/tomoyo/domain_policy.conf.DebTop.orig cp /etc/tomoyo/domain_policy.conf
fi



