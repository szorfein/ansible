#!/usr/bin/env sh

set -o errexit

DAY="$(date +%d-%m-%Y)"
LOG_FILE="/var/log/automatic-update-${DAY}.log"

download() {
  echo "Log saved to $LOG_FILE"
  checkupdates -d >> "$LOG_FILE"
  if [ "$?" -eq 0 ] ; then
    echo "Download success !" >> "$LOG_FILE"
  fi
}

update_grub() {
  if test -d '/sys/firmware/efi/efivars' ; then
    grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB --recheck
  else
    grub-install /dev/xxx
  fi
  grub-mkconfig -o /boot/grub/grub.cfg
}

update_bootloader() {
  if hash grub >/dev/null ; then
    update_grub
  else
    echo "booloader failed" >> "$LOG_FILE"
    exit 1
  fi
}

install() {
  echo "Log saved to $LOG_FILE"
  #{% if mount_boot %}
  # Mount before update, cause vfat should be unavailable after the update
  mount /boot
  mount /efi 
  #{% endif %}
  if grep -qi "download success !" "$LOG_FILE" ; then
    
    pacman -Su --noconfirm >> "$LOG_FILE"
    update_bootloader
  else
    echo "There are a problem with downloads." >> "$LOG_FILE"
    exit 1
  fi
}

main() {
  if [ "$#" -eq 0 ] ; then
    printf "%s\\n" "${0}: Argument required"
    exit 1
  fi

  while [ "$#" -gt 0 ] ; do
    case $1 in
      -d | --download) download ;;
      -i | --install) install ;;
      -- | -* | *) exit 1 ;
    esac
    shift
  done
}

main "$@"
