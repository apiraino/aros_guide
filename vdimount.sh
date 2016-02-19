#!/bin/bash

######### CONFIG #########

# YOUR UID and GID
UID=1000
GID=1000

# FULL PATH OF YOUR FAT32 VDI FILE
SRCPATH="/home/user"

# NAME OF YOUR FAT32 VDI FILE
VDIIMAGE="Fat32.vdi"

# LINUX MOUNT POINT FOR THE VDI FILE
VDIMOUNTPOINT="/media/fat32"

##### END CONFIG #########

if [ -z $1 ]; then
	echo "Usage:" $( basename $0 ) "[ mount | umount]"
	exit 0
fi

#if [[ $UID != 0 ]]; then
#	echo "Please run this script with sudo"
#	echo "sudo $0 $*"
#	exit 0
#fi

# Warning!
# Remember to disconnect the Network Block Device ("qemu-nbd -d") after unmounting the
# partition otherwise the qemu process is not killed ("ps waux | grep nbd") and the
# next time you won't be able to use the same device. You would be obliged to choose
# another one (e.g. /dev/nbd1).

if [ "mount" = $1 ]; then
	echo "Mounting $VDIIMAGE"
	sudo modprobe nbd
	sudo qemu-nbd -c /dev/nbd0 "$SRCPATH/$VDIIMAGE"
	sudo mount /dev/nbd0p1 -o uid=$UID,gid=$GID $VDIMOUNTPOINT
	echo "Please access the Fat32 mountpoint from $VDIMOUNTPOINT"
elif [ "umount" = $1 ]; then
	echo "Umounting $VDIIMAGE"
	sudo umount $VDIMOUNTPOINT
	sudo qemu-nbd -d /dev/nbd0
else
    echo "Command not recognized!"
    exit 0
fi

echo "Done."
exit 0

# Old method when you have virtualbox utils installed
LOOPMOUNTPOINT="/tmp/fat32"
if [ "mount" = $1 ]; then
	echo "Mounting $VDIIMAGE"
	sudo vdfuse -f "$SRCPATH/$VDIIMAGE" -t VDI -w $VDIMOUNTPOINT

	if [ ! -d "$LOOPMOUNTPOINT" ]; then
		mkdir $LOOPMOUNTPOINT
	fi

	sudo mount -o loop -t vfat $VDIMOUNTPOINT/Partition1 $LOOPMOUNTPOINT
	echo "You can now access your Fat32 partition on $LOOPMOUNTPOINT"
elif [ "umount" = $1 ]; then
	echo "Unmounting $VDIIMAGE"
	sudo umount $LOOPMOUNTPOINT
	sudo umount $VDIMOUNTPOINT
	exit 0
else
	echo "Command not recognized!"
	exit 0
fi

echo "Done."
exit 0
