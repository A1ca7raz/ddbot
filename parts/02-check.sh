[[ $EUID != 0 ]] && [[ ! $DRYRUN ]] && errorAndExit 1 "Please run as root!"

if [[ ! $IGNORE_DISTRO ]]; then
  distro_name=$(grep "^ID=" /etc/os-release | cut -d'=' -f2)
  distro_ver=$(grep "^VERSION_ID=" /etc/os-release | cut -d'=' -f2 | sed 's/"//g')

  debug "Checking linux distribution and version..."
  if [[ $distro_name = "debian" ]] && [[ $distro_ver -ge 11 ]]; then
    :
  else
    warn "This system is not recommended for this script. Non-debian-based distributions are not supported!"
    confirmY "Are you sure you want to continue?" || exit 4
  fi
fi

if [[ ! $IGNORE_ARCH ]]; then
  arch=$(uname -m)

  debug "Checking architecture..."
  if [[ $arch != "x86_64" ]]; then
    warn "This architecture is not x86_64."
    confirmN "Are you sure you want to continue?" || exit 4
  fi
fi
