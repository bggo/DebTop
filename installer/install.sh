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
echo "Starting DebTop install"
export PATH=$PATH:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/X11R6/bin
test -x /usr/bin/sudo || exit 1
if ! [ -e /system/xbin/busybox ]; then
        test -x /system/bin/busybox || exit 1
        echo "Remounting /system"
        /usr/bin/sudo /system/bin/mount -o remount,rw /system
        /usr/bin/sudo ln -s /system/bin/busybox /system/xbin/busybox || exit 1
        /usr/bin/sudo /system/bin/mount -o remount,ro /system
        echo "Done"
fi

/usr/bin/sudo sed 's_adas    ALL=NOPASSWD: /etc/init.d/webtop-restart.sh, /etc/init.d/webtop-shutdown.sh, /usr/local/sbin/update-language.pl_adas    ALL=NOPASSWD: ALL_g' /etc/sudoers > /tmp/sudoers.debtop
/usr/bin/sudo cp /etc/sudoers /etc/sudoers.orig
/usr/bin/sudo chmod 440 /tmp/sudoers.debtop
/usr/bin/sudo chgrp root /tmp/sudoers.debtop
/usr/bin/sudo mv /tmp/sudoers.debtop /etc/sudoers

if ! [ -b /dev/block/loop50 ]; then
      /usr/bin/sudo mknod -m600 /dev/block/loop50 b 7 50
fi

if ! [ -d /opt/DebTop ]; then
	echo "Creating /opt/DebTop"
	/usr/bin/sudo mkdir -p /opt/DebTop
	/usr/bin/sudo chmod 755 /opt/DebTop
	/usr/bin/sudo chown adas.adas /opt/DebTop
fi
if ! [ -d /opt/DebTop/media ]; then
	echo "Creating /opt/DebTop/media"
	/usr/bin/sudo mkdir -p /opt/DebTop/media
	/usr/bin/sudo chmod 755 /opt/DebTop/media
	/usr/bin/sudo chown adas.adas /opt/DebTop/media
fi
if ! [ -d /opt/DebTop/root ]; then
	echo "Creating /opt/DebTop/root"
	/usr/bin/sudo mkdir -p /opt/DebTop/root
	/usr/bin/sudo chmod 755 /opt/DebTop/root
	/usr/bin/sudo chown adas.adas /opt/DebTop/root
fi
if ! [ -d /opt/DebTop/icons ]; then
	echo "Creating /opt/DebTop/icons"
	/usr/bin/sudo mkdir -p /opt/DebTop/icons
	/usr/bin/sudo chmod 755 /opt/DebTop/icons
	/usr/bin/sudo chown adas.adas /opt/DebTop/icons

	/usr/bin/sudo cp resources/debian.png /opt/DebTop/icons
	/usr/bin/sudo chmod 644 /opt/DebTop/icons/debian.png
	/usr/bin/sudo chown adas.adas /opt/DebTop/icons/debian.png
fi
if ! [ -d /opt/DebTop/etc ]; then
	echo "Creating /opt/DebTop/etc"
	/usr/bin/sudo mkdir -p /opt/DebTop/etc
	/usr/bin/sudo chmod 755 /opt/DebTop/etc
	/usr/bin/sudo chown adas.adas /opt/DebTop/etc
fi

# Temporarily moved to another branch until problems after
# DebTop install are fixed.

#echo ""
#echo "Do you want me to disable Tomoyo? If unsure just say yes."
#echo "[Y]/n"
#read DIS_TOMOYO
#if [ -z $DIS_TOMOYO ]; then DIS_TOMOYO="y"; fi
#DIS_TOMOYO=`echo $DIS_TOMOYO|cut -c1|tr [:upper:] [:lower:]` 
#
#if [ "$DIS_TOMOYO" = "y" ]; then
#	echo "Disabling Tomoyo..."
#	/usr/bin/sudo mv /etc/tomoyo /etc/tomoyo.DebTop.orig
#	/usr/bin/sudo cp -r resources/tomoyo /etc
#	/usr/bin/sudo chown root.root -R /etc/tomoyo && echo "Tomoyo has been disabled. You'll need to turn your phone off and then on again after we're finished"
#fi

############################# Populate Settings ###############################
> /opt/DebTop/etc/main.cf
/usr/bin/sudo chmod 666 /opt/DebTop/etc/main.cf

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
			/usr/bin/sudo rm /opt/DebTop/linuxdisk
		fi
		/usr/bin/sudo ln -s /sdcard/DebTop/linuxdisk /opt/DebTop/linuxdisk
		echo "DISK=/sdcard/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
	elif [ -f /sdcard-ext/DebTop/linuxdisk ]; then
		if [ -L /opt/DebTop/linuxdisk ]; then
			/usr/bin/sudo rm /opt/DebTop/linuxdisk
		fi
		/usr/bin/sudo ln -s /sdcard-ext/DebTop/linuxdisk /opt/DebTop/linuxdisk
		echo "DISK=/sdcard-ext/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
	else
		echo "No image found!"
		exit 1
	fi
else
	echo "Partitioned SD Card found. Mounting on /opt/DebTop/media"
	/usr/bin/sudo /bin/mount /dev/mmcblk1p2 /opt/DebTop/media
	/usr/bin/sudo chmod -R a+r /opt/DebTop/media/*
	test -f /opt/DebTop/media/DebTop/linuxdisk || exit 1
	if [ -L /opt/DebTop/linuxdisk ]; then
		/usr/bin/sudo rm /opt/DebTop/linuxdisk
	fi
	/usr/bin/sudo ln -s /opt/DebTop/media/DebTop/linuxdisk /opt/DebTop/linuxdisk
	echo "SDPART=/dev/mmcblk1p2" >> /opt/DebTop/etc/main.cf
	echo "DISK=/opt/DebTop/media/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
fi

echo "MEDIA=/opt/DebTop/media" >>  /opt/DebTop/etc/main.cf
echo "DEBROOT=/opt/DebTop/root" >> /opt/DebTop/etc/main.cf
echo "LOOPDEVICE=/dev/block/loop50" >> /opt/DebTop/etc/main.cf

/usr/bin/sudo chown root.root /opt/DebTop/etc/main.cf
/usr/bin/sudo chmod 644 /opt/DebTop/etc/main.cf

echo "Creating DebTop launcher"
/usr/bin/sudo cp resources/debtop /usr/sbin
/usr/bin/sudo touch /usr/share/applications/debtop.desktop
/usr/bin/sudo chmod 666 /usr/share/applications/debtop.desktop
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
/usr/bin/sudo chmod 644 /usr/share/applications/debtop.desktop

echo "Creating DebTop LM launcher"
/usr/bin/sudo touch /usr/share/applications/debtop-lm.desktop
/usr/bin/sudo chmod 666 /usr/share/applications/debtop-lm.desktop
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
/usr/bin/sudo chmod 644 /usr/share/applications/debtop-lm.desktop

LAUNCHERS=`/usr/bin/gconftool -g /apps/avant-window-navigator/window_manager/launchers|cut -f2 -d[|cut -f1 -d]`
LAUNCHERS=`echo $LAUNCHERS,$EXTRA`
/usr/bin/sudo /system/xbin/setuidgid adas /usr/bin/gconftool -s /apps/avant-window-navigator/window_manager/launchers "[$LAUNCHERS]" --type list --list-type string

echo ""
echo "Do you want to add extra software in the apps bar?"
echo "This is often desirable if you plan access other applications in the easy way."
echo "y/[N]"
read PLUS
if [ -z $PLUS ]; then PLUS="y"; fi
if [ $PLUS = "y" ]; then
	. resources/extras.sh
fi

echo "Install complete! Please reboot your phone in order to apply the changes."
