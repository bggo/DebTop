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

############################### Extras ########################################
echo "Probing for additional software in your disk"
/usr/bin/sudo mount -o loop=/dev/block/loop50 /opt/DebTop/linuxdisk /mnt || exit 1


#----------------------------- lxterminal  ------------------------------------
if [ -x /mnt/usr/bin/lxterminal ]; then
	/usr/bin/sudo cp /mnt/usr/share/pixmaps/lxterminal.png /opt/DebTop/icons/lxterminal.png
	/usr/bin/sudo touch /usr/share/applications/debtop-lxterminal.desktop
	/usr/bin/sudo chmod 666 /usr/share/applications/debtop-lxterminal.desktop
	echo "[Desktop Entry]
Encoding=UTF-8
Name=lxterminal
GenericName=lxterminal
Comment=Terminal Emulator
TryExec=/usr/sbin/debtop lxterminal
Exec=/usr/sbin/debtop lxterminal
Icon=/opt/DebTop/icons/lxterminal.png
Type=Application" > /usr/share/applications/debtop-lxterminal.desktop
	/usr/bin/sudo chmod 644 /usr/share/applications/debtop-lxterminal.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-lxterminal.desktop"
	echo "lxterminal"
fi

#----------------------------- Iceweasel --------------------------------------
if [ -x /mnt/usr/bin/iceweasel ]; then
	/usr/bin/sudo cp /mnt/usr/share/icons/hicolor/48x48/apps/iceweasel.png /opt/DebTop/icons/iceweasel.png
	/usr/bin/sudo touch /usr/share/applications/debtop-iceweasel.desktop
	/usr/bin/sudo chmod 666 /usr/share/applications/debtop-iceweasel.desktop
	echo "[Desktop Entry]
Encoding=UTF-8
Name=Iceweasel
GenericName=Iceweasel
Comment=Iceweasel Web Browser
TryExec=/usr/sbin/debtop iceweasel
Exec=/usr/sbin/debtop iceweasel
Icon=/opt/DebTop/icons/iceweasel.png
Type=Application" > /usr/share/applications/debtop-iceweasel.desktop
	/usr/bin/sudo chmod 644 /usr/share/applications/debtop-iceweasel.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-iceweasel.desktop"
	echo "iceweasel"
fi


#----------------------------- Libreoffice ------------------------------------
if [ -x /mnt/usr/bin/libreoffice ]; then
	/usr/bin/sudo cp /mnt/usr/share/icons/hicolor/128x128/apps/libreoffice34-startcenter.png /opt/DebTop/icons/libreoffice.png
	/usr/bin/sudo touch /usr/share/applications/debtop-libreoffice.desktop
	/usr/bin/sudo chmod 666 /usr/share/applications/debtop-libreoffice.desktop
	echo "[Desktop Entry]
Encoding=UTF-8
Name=Libreoffice
GenericName=Libreoffice
Comment=Libreoffice Productivity Suite
TryExec=/usr/sbin/debtop libreoffice
Exec=/usr/sbin/debtop libreoffice
Icon=/opt/DebTop/icons/libreoffice.png
Type=Application" > /usr/share/applications/debtop-libreoffice.desktop
	/usr/bin/sudo chmod 644 /usr/share/applications/debtop-libreoffice.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-libreoffice.desktop"
	echo "libreoffice"
fi


#----------------------------- Transmission ----------------------------------
if [ -x /mnt/usr/bin/transmission-gtk ]; then
	/usr/bin/sudo cp /mnt/usr/share/icons/hicolor/48x48/apps/transmission.png /opt/DebTop/icons/transmission.png
	/usr/bin/sudo touch /usr/share/applications/debtop-transmission.desktop
	/usr/bin/sudo chmod 666 /usr/share/applications/debtop-transmission.desktop
	echo "[Desktop Entry]
Encoding=UTF-8
Name=Transmission
GenericName=Transmission
Comment=Transmission Bittorrent Client
TryExec=/usr/sbin/debtop transmission-gtk
Exec=/usr/sbin/debtop transmission-gtk
Icon=/opt/DebTop/icons/transmission.png
Type=Application" > /usr/share/applications/debtop-transmission.desktop
	/usr/bin/sudo chmod 644 /usr/share/applications/debtop-transmission.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-transmission.desktop"
	echo "transmission"
fi

#---------------------------- Screenshot -------------------------------------
if [ -x /mnt/usr/bin/xfce4-screenshooter ]; then
	/usr/bin/sudo cp /mnt/usr/share/icons/hicolor/48x48/apps/applets-screenshooter.png /opt/DebTop/icons/screenshot.png
	/usr/bin/sudo touch /usr/share/applications/debtop-screenshot.desktop
	/usr/bin/sudo chmod 666 /usr/share/applications/debtop-screenshot.desktop
	echo "[Desktop Entry]
Encoding=UTF-8
Name=Screenshot
GenericName=Screenshot
Comment=Take Screenshots of Your Webtop!
TryExec=/usr/sbin/debtop xfce4-screenshooter
Exec=/usr/sbin/debtop xfce4-screenshooter
Icon=/opt/DebTop/icons/screenshot.png
Type=Application" > /usr/share/applications/debtop-screenshot.desktop
	/usr/bin/sudo chmod 644 /usr/share/applications/debtop-screenshot.desktop
	EXTRA="$EXTRA,/usr/share/applications/debtop-screenshot.desktop"
	echo "xfce4-screenshooter"
fi

#--------------------------------- Synaptic -----------------------------------
if [ -x /mnt/usr/sbin/synaptic ]; then
	/usr/bin/sudo cp /mnt/usr/share/pixmaps/synaptic.png /opt/DebTop/icons/synaptic.png
	/usr/bin/sudo touch /usr/share/applications/debtop-synaptic.desktop
	/usr/bin/sudo chmod 666 /usr/share/applications/debtop-synaptic.desktop
	echo "[Desktop Entry]
Encoding=UTF-8
Name=Screenshot
GenericName=Synaptic
Comment=Install, remove and manage software for you DebTop
TryExec=/usr/sbin/debtop synaptic
Exec=/usr/sbin/debtop synaptic
Icon=/opt/DebTop/icons/synaptic.png
Type=Application" > /usr/share/applications/debtop-synaptic.desktop
	/usr/bin/sudo chmod 644 /usr/share/applications/debtop-synaptic.desktop
        EXTRA="$EXTRA,/usr/share/applications/debtop-synaptic.desktop"
	echo "synaptic"
fi


/usr/bin/sudo umount /mnt

LAUNCHERS=`/usr/bin/gconftool -g /apps/avant-window-navigator/window_manager/launchers|cut -f2 -d[|cut -f1 -d]`
LAUNCHERS=`echo $LAUNCHERS,$EXTRA`
/usr/bin/sudo /system/xbin/setuidgid adas /usr/bin/gconftool -s /apps/avant-window-navigator/window_manager/launchers "[$LAUNCHERS]" --type list --list-type string

