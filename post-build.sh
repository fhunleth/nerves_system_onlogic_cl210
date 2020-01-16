#!/bin/sh

set -e

# Copy everything that's needed to build firmware images over to the
# output directory so that it can be bundled with the system image.
cp $NERVES_DEFCONFIG_DIR/grub.cfg $BINARIES_DIR/efi-part/EFI/BOOT/grub.cfg

# Remove the Buildroot-generated grub.cfg so avoid confusion.
# We put our grub in the FAT filesystem at the beginning of the
# disk so that it exists across firmware updates.
rm -fr $TARGET_DIR/boot/grub/*

# Create the revert script for manually switching back to the previously
# active firmware.
mkdir -p $TARGET_DIR/usr/share/fwup
NERVES_SYSTEM=$BASE_DIR $HOST_DIR/usr/bin/fwup -c -f $NERVES_DEFCONFIG_DIR/fwup-revert.conf -o $TARGET_DIR/usr/share/fwup/revert.fw

# Copy the fwup includes to the images dir
cp -rf $NERVES_DEFCONFIG_DIR/fwup_include $BINARIES_DIR

# Compress the initramfs files
$NERVES_DEFCONFIG_DIR/file-to-cpio.sh "$NERVES_DEFCONFIG_DIR/nerves_initramfs.conf" "$BINARIES_DIR/nerves_initramfs.conf.cpio"
$NERVES_DEFCONFIG_DIR/file-to-cpio.sh "$TARGET_DIR/usr/share/fwup/revert.fw" "$BINARIES_DIR/revert.fw.cpio"
