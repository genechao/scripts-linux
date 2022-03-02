#!/bin/bash
# GRUB Install
# Usage: grub-install.sh
# By: Gene Chao - Last updated: 9/6/2019
GRUB_EFI_ID=GRUB
GRUB_TARGETS=(i386-pc i386-efi x86_64-efi)

echo For Secure Boot: apt install grub-efi-amd64-signed shim-signed
echo For 32-bit UEFI: apt install grub-efi-ia32-bin
echo
echo -n "Mounted boot partition (e.g., /mnt): "
read BOOT_ROOT_DIR
BOOT_DEV=$(lsblk -dnp -o PKNAME "$(mount | grep " on $BOOT_ROOT_DIR " | awk '{printf $1}')")
if [ -z $BOOT_DEV ]; then
	echo -n "Boot device (e.g., /dev/sdX): "
	read BOOT_DEV
else
	echo "Boot device: $BOOT_DEV"
fi

#Usage: grub-install [OPTION...] [OPTION] [INSTALL_DEVICE]
#  -v, --verbose              print verbose messages.
#      --boot-directory=DIR   install GRUB images under the directory DIR/grub
#                             instead of the boot/grub directory
#      --bootloader-id=ID     the ID of bootloader. This option is only
#                             available on EFI and Macs.
#      --efi-directory=DIR    use DIR as the EFI System Partition root.
#      --no-nvram             don't update the `boot-device'/`Boot*' NVRAM
#                             variables. This option is only available on EFI
#                             and IEEE1275 targets.
#      --removable            the installation device is removable. This option
#                             is only available on EFI.
#      --target=TARGET        install GRUB for TARGET platform
#                             x86_64-efi or i386-pc
#      --uefi-secure-boot     install an image usable with UEFI Secure Boot.
#                             This option is only available on EFI and if the
#                             grub-efi-amd64-signed package is installed.
for GRUB_TARGET in ${GRUB_TARGETS[*]}; do
	GRUB_INSTALL_COMMAND="grub-install -v --boot-directory=\"$BOOT_ROOT_DIR/boot\" --bootloader-id=\"$GRUB_EFI_ID\" --efi-directory=\"$BOOT_ROOT_DIR\" --no-nvram --removable --target=\"$GRUB_TARGET\" --uefi-secure-boot \"$BOOT_DEV\""
	echo
	echo Command: $GRUB_INSTALL_COMMAND
	echo -n "Execute? (Y/N): "
	read
	if [ "$REPLY" = "y" -o "$REPLY" = "Y" ]; then
		eval sudo $GRUB_INSTALL_COMMAND
	fi
done
