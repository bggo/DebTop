#!/bin/bash
###############################################################################
# DebTop Installer
#
# This script installs the DebTop envionment on the Motorola Atrix phone. It
# will also create the appropriate launchers on the WebTop bar to applications
# on the Debian image.
#
# Author: Diego Lima <diego@diegolima.org>
# License: GPLv3
###############################################################################
if ! [ -b /dev/block/loop50 ]; then
      sudo mknod -m600 /dev/block/loop50 b 7 50
fi

if ! [ -d /opt/DebTop ]; then
	echo "Creating /opt/DebTop"
	sudo mkdir -p /opt/DebTop
	sudo chmod 755 /opt/DebTop
	sudo chown adas.adas /opt/DebTop
fi
if ! [ -d /opt/DebTop/media ]; then
	echo "Creating /opt/DebTop/media"
	sudo mkdir -p /opt/DebTop/media
	sudo chmod 755 /opt/DebTop/media
	sudo chown adas.adas /opt/DebTop/media
fi
if ! [ -d /opt/DebTop/root ]; then
	echo "Creating /opt/DebTop/root"
	sudo mkdir -p /opt/DebTop/root
	sudo chmod 755 /opt/DebTop/root
	sudo chown adas.adas /opt/DebTop/root
fi
if ! [ -d /opt/DebTop/icons ]; then
	echo "Creating /opt/DebTop/icons"
	sudo mkdir -p /opt/DebTop/icons
	sudo chmod 755 /opt/DebTop/icons
	sudo chown adas.adas /opt/DebTop/icons

	sudo cp resources/debian.png /opt/DebTop/icons
	sudo chmod 644 /opt/DebTop/icons/debian.png
	sudo chown adas.adas /opt/DebTop/icons/debian.png
fi
if ! [ -d /opt/DebTop/etc ]; then
	echo "Creating /opt/DebTop/etc"
	sudo mkdir -p /opt/DebTop/etc
	sudo chmod 755 /opt/DebTop/etc
	sudo chown adas.adas /opt/DebTop/etc
fi

###############################################################################
# WARNING! Here Be Dragons
# This feature might have caused at least one phone to become unusable
###############################################################################
#echo ""
#echo "Do you want me to disable Tomoyo? If unsure just say yes."
#echo "[Y]/n"
#read DIS_TOMOYO
#if [ -z $DIS_TOMOYO ]; then DIS_TOMOYO="y"; fi
#DIS_TOMOYO=`echo $DIS_TOMOYO|cut -c1|tr [:upper:] [:lower:]` 
#
#if [ "$DIS_TOMOYO" = "y" ]; then
#	echo "Disabling Tomoyo..."
#	sudo cp /etc/tomoyo/domain_policy.conf /etc/tomoyo/domain_policy.conf.DebTop.orig
#	sudo cp /etc/tomoyo/domain_policy.conf /etc/tomoyo/domain_policy.conf.DebTop.`date +%Y%m%d%H%M`
#	sudo sed 's/use_profile 3/use_profile 0/g' /etc/tomoyo/domain_policy.conf > /etc/tomoyo/domain_policy.conf.tmp || exit 2
#	sudo mv /etc/tomoyo/domain_policy.conf.tmp /etc/tomoyo/domain_policy.conf
#	echo "Tomoyo has been disabled. You'll need to turn your phone off and then on again after we're finished"
#fi

############################# Populate Settings ###############################
> /opt/DebTop/etc/main.cf
sudo chmod 666 /opt/DebTop/etc/main.cf

echo ""
echo "Do you want to enable accented characters (dead keys support)?"
echo "This is often desirable if you plan to write in any language other than english."
echo "y/[N]"
read DEADKEYS
if [ -z $DEADKEYS ]; then DEADKEYS="n"; fi
DEADKEYS=`echo $DEADKEYS|cut -c1|tr [:upper:] [:lower:]`

if [ $DEADKEYS = "y" ]; then
	echo "Enabling dead keys support"
	echo "DEADKEYS=y" >> /opt/DebTop/etc/main.cf
fi

if ! [ -b /dev/mmcblk1p2 ]; then
	echo "Partitioned SD Card NOT found."
	echo "We will not support DebTop systems larger than 4gb"
	if [ -f /sdcard/DebTop/linuxdisk ]; then
		if [ -L /opt/DebTop/linuxdisk ]; then
			sudo rm /opt/DebTop/linuxdisk
		fi
		sudo ln -s /sdcard/DebTop/linuxdisk /opt/DebTop/linuxdisk
		echo "DISK=/sdcard/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
	elif [ -f /sdcard-ext/DebTop/linuxdisk ]; then
		if [ -L /opt/DebTop/linuxdisk ]; then
			sudo rm /opt/DebTop/linuxdisk
		fi
		sudo ln -s /sdcard-ext/DebTop/linuxdisk /opt/DebTop/linuxdisk
		echo "DISK=/sdcard-ext/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
	else
		echo "No image found!"
		exit 1
	fi
else
	echo "Partitioned SD Card found. Mounting on /opt/DebTop/media"
	mount /dev/mmcblk1p2 /opt/DebTop/media
	sudo chmod -R a+r /opt/DebTop/media/*
	test -f /opt/DebTop/media/DebTop/linuxdisk || exit 1
	if [ -L /opt/DebTop/linuxdisk ]; then
		sudo rm /opt/DebTop/linuxdisk
	fi
	sudo ln -s /opt/DebTop/media/DebTop/linuxdisk /opt/DebTop/linuxdisk
	echo "SDPART=/dev/mmcblk1p2" >> /opt/DebTop/etc/main.cf
	echo "DISK=/opt/DebTop/media/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
fi

echo "MEDIA=/opt/DebTop/media" >>  /opt/DebTop/etc/main.cf
echo "DEBROOT=/opt/DebTop/root" >> /opt/DebTop/etc/main.cf
echo "LOOPDEVICE=/dev/block/loop50" >> /opt/DebTop/etc/main.cf

sudo chown root.root /opt/DebTop/etc/main.cf
sudo chmod 644 /opt/DebTop/etc/main.cf

echo "Creating DebTop launcher"
sudo cp resources/debtop /usr/sbin
sudo touch /usr/share/applications/debtop.desktop
sudo chmod 666 /usr/share/applications/debtop.desktop
echo "[Desktop Entry]
Encoding=UTF-8
Name=DebTop
GenericName=DebTop
Comment=Lauch DebTop Linux Environment
TryExec=/usr/sbin/debtop
Exec=/usr/sbin/debtop
Icon=/opt/DebTop/icons/debian.png
Type=Application" > /usr/share/applications/debtop.desktop
EXTRA="/usr/share/applications/debtop.desktop"
sudo chmod 644 /usr/share/applications/debtop.desktop

echo "Creating DebTop LM launcher"
sudo touch /usr/share/applications/debtop-lm.desktop
sudo chmod 666 /usr/share/applications/debtop-lm.desktop
echo "[Desktop Entry]
Encoding=UTF-8
Name=DebTopLM
GenericName=DebTopLM
Comment=DebTop Launcher Manager
TryExec=/usr/sbin/debtop launcher-manager
Exec=/usr/sbin/debtop launcher-manager
Icon=/opt/DebTop/icons/debian.png
Type=Application" > /usr/share/applications/debtop-lm.desktop
EXTRA="$EXTRA,/usr/share/applications/debtop-lm.desktop"
sudo chmod 644 /usr/share/applications/debtop-lm.desktop

LAUNCHERS=`gconftool -g /apps/avant-window-navigator/window_manager/launchers|cut -f2 -d[|cut -f1 -d]`
LAUNCHERS=`echo $LAUNCHERS,$EXTRA`
gconftool -s /apps/avant-window-navigator/window_manager/launchers "[$LAUNCHERS]" --type list --list-type string

echo ""
echo "Do you want to add extra software in the apps bar?"
echo "This is often desirable if you plan access other applications in the easy way."
echo "y/[N]"
read PLUS
if [ -z $PLUS ]; then PLUS="y"; fi
if [ $PLUS = "y" ]; then
	. resources/extras.sh
fi
