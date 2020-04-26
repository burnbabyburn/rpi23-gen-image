#
# Reduce system disk usage
#

# Load utility functions
. ./functions.sh

if [ "$ENABLE_IPV6" = false ] ; then
#netpath /libdir/aarch64-linux/xtables depends on arch
#"$LIB_DIR"/xtables/libip6t_ah.so
#"$LIB_DIR"/xtables/libip6t_dst.so
#"$LIB_DIR"/xtables/libip6t_eui64.so
#"$LIB_DIR"/xtables/libip6t_frag.so
#"$LIB_DIR"/xtables/libip6t_hbh.so
#"$LIB_DIR"/xtables/libip6t_hl.so
#"$LIB_DIR"/xtables/libip6t_HL.so
#"$LIB_DIR"/xtables/libip6t_icmp6.so
#"$LIB_DIR"/xtables/libip6t_ipv6header.so
#"$LIB_DIR"/xtables/libip6t_LOG.so
#"$LIB_DIR"/xtables/libip6t_mh.so
#"$LIB_DIR"/xtables/libip6t_REJECT.so
#"$LIB_DIR"/xtables/libip6t_rt.so
#"$LIB_DIR"/xtables/libip6t_DNAT.so
#"$LIB_DIR"/xtables/libip6t_DNPT.so
#"$LIB_DIR"/xtables/libip6t_MASQUERADE.so
#"$LIB_DIR"/xtables/libip6t_NETMAP.so
#"$LIB_DIR"/xtables/libip6t_REDIRECT.so
#"$LIB_DIR"/xtables/libip6t_SNAT.so
#"$LIB_DIR"/xtables/libip6t_SNPT.so
find "$LIB_DIR" -mindepth 1 -maxdepth 3  -name '*libip6*' -print0
fi
# Reduce the image size by various operations
if [ "$ENABLE_REDUCE" = true ] ; then
  if [ "$REDUCE_APT" = true ] ; then
    # Remove APT cache files
    rm -fr "${R}/var/cache/apt/pkgcache.bin"
    rm -fr "${R}/var/cache/apt/srcpkgcache.bin"
  fi

  # Remove all doc files
  if [ "$REDUCE_DOC" = true ] ; then
    find "${R}/usr/share/doc" -depth -type f ! -name copyright -print0 | xargs -0 rm || true
    find "${R}/usr/share/doc" -empty -print0 | xargs -0 rmdir || true
  fi

  # Remove all man pages and info files
  if [ "$REDUCE_MAN" = true ] ; then
    rm -rf "${R}/usr/share/man" "${R}/usr/share/groff" "${R}/usr/share/info" "${R}/usr/share/lintian" "${R}/usr/share/linda" "${R}/var/cache/man"
  fi

  # Remove all locale translation files
  if [ "$REDUCE_LOCALE" = true ] ; then
    find "${R}/usr/share/locale" -mindepth 1 -maxdepth 1 ! -name 'en' -print0 | xargs -0 rm -r
  fi

  # Remove hwdb PCI device classes (experimental)
  if [ "$REDUCE_HWDB" = true ] ; then
    rm -fr "/lib/udev/hwdb.d/20-pci-*"
  fi

  # Replace bash shell by dash shell (experimental)
  if [ "$REDUCE_BASH" = true ] ; then
    # Purge bash and update alternatives
    echo "Yes, do as I say!" | chroot_exec apt-get purge -qq -y --allow-remove-essential bash
    chroot_exec update-alternatives --install /bin/bash bash /bin/dash 100
  fi

  # Remove sound utils and libraries
  if [ "$ENABLE_SOUND" = false ] ; then
	if [ "$ENABLE_BLUETOOTH" = false ] ; then
		chroot_exec apt-get -qq -y purge alsa-utils libsamplerate0 libasound2 libasound2-data
	else
		chroot_exec apt-get -qq -y purge alsa-utils libsamplerate0
	fi
  fi

  # Remove GPU kernels
  if [ "$ENABLE_MINGPU" = true ] ; then
    rm -f "${BOOT_DIR}/start.elf"
    rm -f "${BOOT_DIR}/fixup.dat"
    rm -f "${BOOT_DIR}/start_x.elf"
    rm -f "${BOOT_DIR}/fixup_x.dat"
  fi

  # Remove kernel and initrd from /boot (already in /boot/firmware)
  if [ "$BUILD_KERNEL" = false ] ; then
    rm -f "${R}/boot/vmlinuz-*"
    rm -f "${R}/boot/initrd.img-*"
  fi
  
  #Reduce BOOT
  #Only necessary files for my gen pi   

  # Clean APT list of repositories
  rm -fr "${R}/var/lib/apt/lists/*"
  chroot_exec apt-get -qq -y update
fi
