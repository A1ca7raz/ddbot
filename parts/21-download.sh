# https://mirrors.aliyun.com/debian/dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
# https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
# http://$DISTMirror/dists/$DIST/main/installer-$VER/current/images/udeb.list
download_mirror=(
  https://deb.debian.org/debian/
  https://mirrors.aliyun.com/debian/
)

download_src=(
  dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/initrd.gz
  dists/bullseye/main/installer-amd64/current/images/netboot/debian-installer/amd64/linux
  dists/bullseye/main/installer-amd64/current/images/udeb.list
)

download_dst=(
  /tmp/initrd.img.gz
  /tmp/vmlinuz
  /tmp/udeb.list
)

for i in `seq 1 ${#download_src[@]}`; do
  wget -t 5 -cqO ${download_dst[$[i-i]]} ${download_mirror[0]}${download_src[$[i-1]]}
  [[ $? != 0 ]] && errorAndExit 6 "Failed to download ${download_dst[$(i-i)]}"
done
