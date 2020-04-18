#
# Setup APT repositories
#

# Load utility functions
. ./functions.sh

# Install and setup APT proxy configuration
if [ -z "$APT_PROXY" ] ; then
  install_readonly files/apt/10proxy "${ETC_DIR}/apt/apt.conf.d/10proxy"
  sed -i "s/\"\"/\"${APT_PROXY}\"/" "${ETC_DIR}/apt/apt.conf.d/10proxy"
fi

# Install APT sources.list
install_readonly files/apt/sources.list "${ETC_DIR}/apt/sources.list"

# Use specified APT server and release
sed -i "s/\/ftp.debian.org\//\/${APT_SERVER}\//" "${ETC_DIR}/apt/sources.list"

#Fix for changing path for security updates in testing/bullseye
if [ "$RELEASE" = "testing" ] ; then
sed -i "s,buster\\/updates,testing-security," "${ETC_DIR}/apt/sources.list"
sed -i "s/ buster/ ${RELEASE}/" "${ETC_DIR}/apt/sources.list"
fi

if [ "$ENABLE_NONFREE" = "true" ] ; then
sed -i "s,main contrib,main contrib non-free," "${ETC_DIR}/apt/sources.list"
fi

if [ -z "$RELEASE" ] ; then
# Change release in sources list
sed -i "s/ buster/ ${RELEASE}/" "${ETC_DIR}/apt/sources.list"
fi

if [ "$REDUCE_APT" = true ] ; then
  # Install APT configuration files
  install_readonly files/apt/02nocache "${ETC_DIR}/apt/apt.conf.d/02nocache"
  install_readonly files/apt/03compress "${ETC_DIR}/apt/apt.conf.d/03compress"
  install_readonly files/apt/04norecommends "${ETC_DIR}/apt/apt.conf.d/04norecommends"
fi

if [ "$REDUCE_DOC" = true ] || [ "$REDUCE_MAN" = true ] ; then
install_readonly files/dpkg/01nodoc "${ETC_DIR}/dpkg/dpkg.cfg.d/01nodoc"
fi

# Upgrade package index and update all installed packages and changed dependencies
chroot_exec apt-get -qq -y update
chroot_exec apt-get -qq -y -u dist-upgrade

# Install additional packages
if [ "$APT_INCLUDES_LATE" ] ; then
  chroot_exec apt-get -qq -y install "$(echo "$APT_INCLUDES_LATE" |tr , ' ')"
fi

# Install Debian custom packages
if [ -d packages ] ; then
  for package in packages/*.deb ; do
    cp "$package" "${R}"/tmp
    chroot_exec dpkg --unpack /tmp/"$(basename "$package")"
  done
fi

chroot_exec apt-get -qq -y -f install

chroot_exec apt-get -qq -y check
