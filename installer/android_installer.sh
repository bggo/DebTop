#!/bin/bash
###############################################################################
# DebTop Installer
#
# This script installs the DebTop envionment on the Motorola Atrix phone. It
# will also create the appropriate launchers on the WebTop bar to applications
# on the Debian image.
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

echo ""
echo "Do you want me to disable Tomoyo? If unsure just say yes."
echo "[Y]/n"
read DIS_TOMOYO

if [ -z $DIS_TOMOYO ]; then
	DIS_TOMOYO="y"
fi
DIS_TOMOYO=`echo $DIS_TOMOYO|tr [:upper:] [:lower:]` 

if [ "$DIS_TOMOYO" = "y" ]; then
	echo "Disabling Tomoyo..."
	sudo cp /etc/tomoyo/domain_policy.conf /etc/tomoyo/domain_policy.conf.DebTop.`date +%Y%m%d%H%M`
	sudo sed 's/use_profile 3/use_profile 0/g' /etc/tomoyo/domain_policy.conf > /etc/tomoyo/domain_policy.conf.tmp || exit 2
	sudo mv /etc/tomoyo/domain_policy.conf.tmp /etc/tomoyo/domain_policy.conf
	echo "Tomoyo has been disabled. You'll need to turn your phone off and then on again after we're finished"
fi

############################# Populate Settings ###############################
> /opt/DebTop/etc/main.cf

if ! [ -b /dev/mmcblk1p2 ]; then
	echo "Partitioned SD Card NOT found."
	echo "We will not support DebTop systems larger than 4gb"
	if [ -f /sdcard/DebTop/linuxdisk ]; then
		if [ -L /opt/DebTop/linuxdisk ]; then
			sudo rm /opt/DebTop/linuxdisk
		fi
		sudo ln -s /sdcard/DebTop/linuxdisk /opt/DebTop/linuxdisk
		sudo echo "DISK=/sdcard/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
	elif [ -f /sdcard-ext/DebTop/linuxdisk ]; then
		if [ -L /opt/DebTop/linuxdisk ]; then
			sudo rm /opt/DebTop/linuxdisk
		fi
		sudo ln -s /sdcard-ext/DebTop/linuxdisk /opt/DebTop/linuxdisk
		sudo echo "DISK=/sdcard-ext/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
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
	sudo echo "SDPART=/dev/mmcblk1p2" >> /opt/DebTop/etc/main.cf
	sudo echo "DISK=/opt/DebTop/media/DebTop/linuxdisk" >> /opt/DebTop/etc/main.cf
fi

sudo echo "MEDIA=/opt/DebTop/media" >>  /opt/DebTop/etc/main.cf
sudo echo "DEBROOT=/opt/DebTop/root" >> /opt/DebTop/etc/main.cf
sudo echo "LOOPDEVICE=/dev/block/loop50" >> /opt/DebTop/etc/main.cf


echo "Creating DebTop launcher"
sudo cp resources/debtop /usr/sbin
sudo touch /usr/share/applications/debtop.desktop
sudo chmod 666 /usr/share/applications/debtop.desktop
sudo echo "[Desktop Entry]
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

############################### Extras ########################################
echo "Probing for additional software in your disk"
sudo mount -o loop=/dev/block/loop50 /opt/DebTop/linuxdisk /mnt || exit 1


#----------------------------- lxterminal  ------------------------------------
if [ -x /mnt/usr/bin/lxterminal ]; then
	sudo cp /mnt/usr/share/pixmaps/lxterminal.png /opt/DebTop/icons/lxterminal.png
	sudo touch /usr/share/applications/debtop-lxterminal.desktop
	sudo chmod 666 /usr/share/applications/debtop-lxterminal.desktop
	sudo echo "[Desktop Entry]
Encoding=UTF-8
Name=lxterminal
GenericName=lxterminal
Comment=Terminal Emulator
TryExec=/usr/sbin/debtop lxterminal
Exec=/usr/sbin/debtop lxterminal
Icon=/opt/DebTop/icons/lxterminal.png
Type=Application" > /usr/share/applications/debtop-lxterminal.desktop
	sudo chmod 644 /usr/share/applications/debtop-lxterminal.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-lxterminal.desktop"
	echo "lxterminal"
fi

#----------------------------- Iceweasel --------------------------------------
if [ -x /mnt/usr/bin/iceweasel ]; then
	sudo cp /mnt/usr/share/icons/hicolor/48x48/apps/iceweasel.png /opt/DebTop/icons/iceweasel.png
	sudo touch /usr/share/applications/debtop-iceweasel.desktop
	sudo chmod 666 /usr/share/applications/debtop-iceweasel.desktop
	sudo echo "[Desktop Entry]
Encoding=UTF-8
Name=Iceweasel
GenericName=Iceweasel
Comment=Iceweasel Web Browser
TryExec=/usr/sbin/debtop iceweasel
Exec=/usr/sbin/debtop iceweasel
Icon=/opt/DebTop/icons/iceweasel.png
Type=Application" > /usr/share/applications/debtop-iceweasel.desktop
	sudo chmod 644 /usr/share/applications/debtop-iceweasel.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-iceweasel.desktop"
	echo "iceweasel"
fi


#----------------------------- Libreoffice ------------------------------------
if [ -x /mnt/usr/bin/libreoffice ]; then
	sudo cp /mnt/usr/share/icons/hicolor/128x128/apps/libreoffice34-startcenter.png /opt/DebTop/icons/libreoffice.png
	sudo touch /usr/share/applications/debtop-libreoffice.desktop
	sudo chmod 666 /usr/share/applications/debtop-libreoffice.desktop
	sudo echo "[Desktop Entry]
Encoding=UTF-8
Name=Libreoffice
GenericName=Libreoffice
Comment=Libreoffice Productivity Suite
TryExec=/usr/sbin/debtop libreoffice
Exec=/usr/sbin/debtop libreoffice
Icon=/opt/DebTop/icons/libreoffice.png
Type=Application" > /usr/share/applications/debtop-libreoffice.desktop
	sudo chmod 644 /usr/share/applications/debtop-libreoffice.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-libreoffice.desktop"
	echo "libreoffice"
fi


#----------------------------- Transmission ----------------------------------
if [ -x /mnt/usr/bin/transmission-gtk ]; then
	sudo cp /mnt/usr/share/icons/hicolor/48x48/apps/transmission.png /opt/DebTop/icons/transmission.png
	sudo touch /usr/share/applications/debtop-transmission.desktop
	sudo chmod 666 /usr/share/applications/debtop-transmission.desktop
	sudo echo "[Desktop Entry]
Encoding=UTF-8
Name=Transmission
GenericName=Transmission
Comment=Transmission Bittorrent Client
TryExec=/usr/sbin/debtop transmission-gtk
Exec=/usr/sbin/debtop transmission-gtk
Icon=/opt/DebTop/icons/transmission.png
Type=Application" > /usr/share/applications/debtop-transmission.desktop
	sudo chmod 644 /usr/share/applications/debtop-transmission.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-transmission.desktop"
	echo "transmission"
fi

#---------------------------- Screenshot -------------------------------------
if [ -x /mnt/usr/bin/xfce4-screenshooter ]; then
	sudo cp /mnt/usr/share/icons/hicolor/48x48/apps/applets-screenshooter.png /opt/DebTop/icons/screenshot.png
	sudo touch /usr/share/applications/debtop-screenshot.desktop
	sudo chmod 666 /usr/share/applications/debtop-screenshot.desktop
	sudo echo "[Desktop Entry]
Encoding=UTF-8
Name=Screenshot
GenericName=Screenshot
Comment=Take Screenshots of Your Webtop!
TryExec=/usr/sbin/debtop xfce4-screenshooter
Exec=/usr/sbin/debtop xfce4-screenshooter
Icon=/opt/DebTop/icons/screenshot.png
Type=Application" > /usr/share/applications/debtop-screenshot.desktop
	sudo chmod 644 /usr/share/applications/debtop-screenshot.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-screenshot.desktop"
	echo "xfce4-screenshooter"
fi

#--------------------------------- Synaptic -----------------------------------
if [ -x /mnt/usr/sbin/synaptic ]; then
	sudo cp icon 
	sudo touch /usr/share/applications/debtop-synaptic.desktop
	sudo chmod 666 /usr/share/applications/debtop-synaptic.desktop
	sudo echo "[Desktop Entry]
Encoding=UTF-8
Name=Screenshot
GenericName=Synaptic
Comment=Install, remove and manage software for you DebTop
TryExec=/usr/sbin/debtop synaptic
Exec=/usr/sbin/debtop synaptic
Icon=/opt/DebTop/icons/synaptic.png
Type=Application" > /usr/share/applications/debtop-synaptic.desktop
	sudo chmod 644 /usr/share/applications/debtop-synaptic.desktop
        EXTRA="$EXTRA,/usr/share/applications/debtop-synaptic.desktop"
	echo "synaptic"
fi


sudo umount /mnt

LAUNCHERS=`gconftool -g /apps/avant-window-navigator/window_manager/launchers|cut -f2 -d[|cut -f1 -d]`
LAUNCHERS=`echo $LAUNCHERS,$EXTRA`
gconftool -s /apps/avant-window-navigator/window_manager/launchers "[$LAUNCHERS]" --type list --list-type string


