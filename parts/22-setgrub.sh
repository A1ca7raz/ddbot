function getGRUB() {
  ls /boot/grub/grub.cfg 2>/dev/null || errorAndExit 8 "Failed to get GRUB.cfg."

  # cat $GRUBDIR/$GRUBFILE |sed -n '1h;1!H;$g;s/\n/%%%%%%%/g;$p' |grep -om 1 'menuentry\ [^{]*{[^}]*}%%%%%%%' |sed 's/%%%%%%%/\n/g' > /tmp/grub.read
}

BOOT_UUID=`findmnt -n -o uuid -T /boot`

debug "Getting GRUB config..."
getGRUB

debug "Adding boot entry..."
sed 's/--id ddbot/--id deprecated/g' -i /boot/grub/grub.cfg
cat >> /boot/grub/grub.cfg << EOF
menuentry 'Install' --id ddbot {
	load_video
	insmod gzio
	insmod part_msdos
	insmod ext2
	search --no-floppy -fs-uuid --set=root ${BOOT_UUID}
	linux /boot/vmlinuz-dd auto=true hostname=ddbot domain=ddbot net.ifnames=0 biosdevname=0
	initrd /boot/initrd-dd.img
}

set default=install
EOF
