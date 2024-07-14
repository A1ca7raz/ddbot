OPERATION=run
CFG=$default_cfg
CFG_UNFINISHED=1
NET_IP=
NET_MASK=
NET_MASK_NUM=
NET_GATEWAY=
NET_DNS=
NET_IFACE= # only used in gencfg
SYS_DISK=
IMAGE_URL=
SCALE_PARTITION=
MOUNT_OPTIONS=mount
NETWORKD_DIR=/etc/systemd/networkd/
IGNORE_DISTRO=
IGNORE_ARCH=

while [[ $# -ge 1 ]]; do
  case $1 in
    -h|-H|--help)
      shift
      echo
      usage
      exit 0
      ;;
    -c|--config)
      shift
      CFG=$1
      shift
      ;;
    -d|--debug)
      shift
      DEBUG=1
      ;;
    --dry-run)
      shift
      DRYRUN=echo -E
      ;;
    *)
      echo -e "$app_name: Invaild option: $1"
      usage
      exit 1
      ;;
  esac
done

check_file $CFG || OPERATION=gencfg
