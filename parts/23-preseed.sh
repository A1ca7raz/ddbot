[[ -d /tmp/boot ]] && rm -rf /tmp/boot
mkdir -p /tmp/boot && cd /tmp/boot

debug "Unpacking initrd.img..."
gzip -d < /tmp/initrd.img.gz | cpio --extract --verbose --make-directories --no-absolute-filenames >> /dev/null 2>&1

case $SCALE_PARTITION in
  btrfs)
    scaleScript="partx -u ${SYS_DISK}
btrfs filesystem resize max \`ls ${SYS_DISK}* | tail -n1\`"
  ;;
  *)
  ;;
esac

debug "Generating preseed.cfg..."
cat > /tmp/boot/preseed.cfg << EOF
d-i debian-installer/locale string en_US.UTF-8
d-i debian-installer/country string US
d-i debian-installer/language string en

d-i console-setup/layoutcode string us

d-i keyboard-configuration/xkb-keymap string us

d-i netcfg/choose_interface select auto

d-i netcfg/disable_autoconfig boolean true
d-i netcfg/dhcp_failed note
d-i netcfg/dhcp_options select Configure network manually
d-i netcfg/get_ipaddress string $NET_IP
d-i netcfg/get_netmask string $NET_MASK
d-i netcfg/get_gateway string $NET_GATEWAY
d-i netcfg/get_nameservers string $NET_DNS
d-i netcfg/no_default_route boolean true
d-i netcfg/confirm_static boolean true

d-i hw-detect/load_firmware boolean true

d-i mirror/country string manual
d-i mirror/http/hostname string mirrors.edge.kernel.org
d-i mirror/http/directory string /debian
d-i mirror/http/proxy string

d-i passwd/root-login boolean ture
d-i passwd/make-user boolean false
d-i passwd/root-password-crypted password \$6\$G1dLfirFvLFHUpq7\$SNggocv9A9XjaG6nG1Cst/QPk74oDsFyS8ED/GjBotUsqafcbgpmJmCl1l7Y948V97W8jInPrPP5EmXJ3IfY//

d-i clock-setup/utc boolean true
d-i time/zone string US/Eastern
d-i clock-setup/ntp boolean false

d-i preseed/early_command string anna-install libcrypto1.1-udeb libpcre2-8-0-udeb libssl1.1-udeb libuuid1-udeb zlib1g-udeb wget-udeb kpartx-udeb btrfs-progs-udeb
d-i partman/early_command string [[ -n "\$(blkid -t TYPE='vfat' -o device)" ]] && umount "\$(blkid -t TYPE='vfat' -o device)"; \
debconf-set partman-auto/disk "\$(list-devices disk |head -n1)"; \
wget -qO- '$IMAGE_URL' | gunzip -dc | /bin/dd of=\$(list-devices disk |head -n1); \
${scaleScript} \
mkdir /mount \
$MOUNT_OPTIONS \`ls ${SYS_DISK}* | tail -n1\` /mount \
echo "[Match]" > /mount${NETWORKD_DIR}/eth0.network \
echo "Name=eth0" >> /mount${NETWORKD_DIR}/eth0.network \
echo >> /mount${NETWORKD_DIR}/eth0.network \
echo "[Network]" >> /mount${NETWORKD_DIR}/eth0.network \
echo "Address=$NET_IP/$NET_MASK_NUM" >> /mount${NETWORKD_DIR}/eth0.network \
echo "Gateway=$NET_GATEWAY" >> /mount${NETWORKD_DIR}/eth0.network \
for i in ${NET_DNS[@]}; do echo "DNS=$" >> /mount${NETWORKD_DIR}/eth0.network ; done \
echo >> /mount${NETWORKD_DIR}/eth0.network \
/sbin/reboot; \
umount /media || true; \

EOF

debug "Repack initrd.img..."
find . | cpio -H newc --create --verbose | gzip -9 > /tmp/initrd.img;

debug "Copying system image..."
cp -f /tmp/initrd.img /boot/initrd-dd.img || sudo cp -f /tmp/initrd.img /boot/initrd-dd.img
cp -f /tmp/vmlinuz /boot/vmlinuz-dd || sudo cp -f /tmp/vmlinuz /boot/vmlinuz-dd

chown root:root $GRUBDIR/$GRUBFILE
chmod 444 $GRUBDIR/$GRUBFILE

info "Finished. Reboot 3 seconds later..."
sleep 3 && reboot || sudo reboot >/dev/null 2>&1
