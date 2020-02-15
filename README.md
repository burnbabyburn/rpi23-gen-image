# rpi23-gen-image
## Introduction
`rpi23-gen-image.sh` is an advanced Debian Linux bootstrapping shell script for generating Debian OS images for all Raspberry Pi computers. The script at this time supports the bootstrapping of the Debian (armhf/armel) releases `stretch` and `buster`. Raspberry Pi 0/1/2/3/4 images are generated for 32-bit mode only. Raspberry Pi 3 supports 64-bit images that can be generated using custom configuration parameters (```templates/rpi3-stretch-arm64-4.14.y```).

## Build dependencies
The following list of Debian packages must be installed on the build system because they are essentially required for the bootstrapping process. The script will check if all required packages are installed and missing packages will be installed automatically if confirmed by the user.

  ```debootstrap debian-archive-keyring qemu-user-static binfmt-support dosfstools rsync bmap-tools whois git bc psmisc dbus sudo```

It is recommended to configure the `rpi23-gen-image.sh` script to build and install the latest Raspberry Pi Linux kernel. For the Raspberry 3 this is mandatory. Kernel compilation and linking will be performed on the build system using an ARM (armhf/armel/aarch64) cross-compiler toolchain.

The script has been tested using the default `crossbuild-essential-armhf` and `crossbuild-essential-armel` toolchain meta packages on Debian Linux `stretch` build systems. Please check the [Debian CrossToolchains Wiki](https://wiki.debian.org/CrossToolchains) for further information.

## Command-line parameters
The script accepts certain command-line parameters to enable or disable specific OS features, services and configuration settings. These parameters are passed to the `rpi23-gen-image.sh` script via (simple) shell-variables. Unlike environment shell-variables (simple) shell-variables are defined at the beginning of the command-line call of the `rpi23-gen-image.sh` script.

##### Command-line examples:
```shell
ENABLE_UBOOT=true ./rpi23-gen-image.sh
ENABLE_CONSOLE=false ENABLE_IPV6=false ./rpi23-gen-image.sh
ENABLE_WM=xfce4 ENABLE_FBTURBO=true ENABLE_MINBASE=true ./rpi23-gen-image.sh
ENABLE_HARDNET=true ENABLE_IPTABLES=true /rpi23-gen-image.sh
APT_SERVER=ftp.de.debian.org APT_PROXY="http://127.0.0.1:3142/" ./rpi23-gen-image.sh
ENABLE_MINBASE=true ./rpi23-gen-image.sh
BUILD_KERNEL=true ENABLE_MINBASE=true ENABLE_IPV6=false ./rpi23-gen-image.sh
BUILD_KERNEL=true KERNELSRC_DIR=/tmp/linux ./rpi23-gen-image.sh
ENABLE_MINBASE=true ENABLE_REDUCE=true ENABLE_MINGPU=true BUILD_KERNEL=true ./rpi23-gen-image.sh
ENABLE_CRYPTFS=true CRYPTFS_PASSWORD=changeme EXPANDROOT=false ENABLE_MINBASE=true ENABLE_REDUCE=true ENABLE_MINGPU=true BUILD_KERNEL=true ./rpi23-gen-image.sh
RELEASE=buster BUILD_KERNEL=true ./rpi23-gen-image.sh
RPI_MODEL=3 ENABLE_WIRELESS=true ENABLE_MINBASE=true BUILD_KERNEL=true ./rpi23-gen-image.sh
RELEASE=buster RPI_MODEL=3 ENABLE_WIRELESS=true ENABLE_MINBASE=true BUILD_KERNEL=true ./rpi23-gen-image.sh
```

## Configuration template files
To avoid long lists of command-line parameters and to help to store the favourite parameter configurations the `rpi23-gen-image.sh` script supports so called configuration template files (`CONFIG_TEMPLATE`=template). These are simple text files located in the `./templates` directory that contain the list of configuration parameters that will be used. New configuration template files can be added to the `./templates` directory.

##### Command-line examples:
```shell
CONFIG_TEMPLATE=rpi3stretch ./rpi23-gen-image.sh
CONFIG_TEMPLATE=rpi2stretch ./rpi23-gen-image.sh
```

## Supported parameters and settings

#### APT settings:
|Option|Value|default value|value format|desciption|
|---|---|---|---|---|
|APT_SERVER|string|ftp.debian.org|URL|Set Debian packages server address. Choose a server from the list of Debian worldwide [mirror sites](https://www.debian.org/mirror/list). Using a nearby server will probably speed-up all required downloads within the bootstrapping process.|
|APT_PROXY|string||URL - e.g. http(s)://user:password@host.domain:port|Set Proxy server address. Using a local Proxy-Cache like `apt-cacher-ng` will speed-up the bootstrapping process because all required Debian packages will only be downloaded from the Debian mirror site once. If `apt-cacher-ng` is running on default `http://127.0.0.1:3142` it is autodetected and you don't need to set this.|
|KEEP_APT_PROXY|boolean|false|true|false|Keep the APT_PROXY settings used in the bootsrapping process in the generated image|


##### `APT_INCLUDES`
|value|string list`
|default|
|format|package0,package1,package2...`
|description:** A comma-separated list of additional packages to be installed by debootstrap during bootstrapping.

##### `APT_INCLUDES_LATE`
|value|string list`
|default|
|format|package0,package1,package2...`
|description:** A comma-separated list of additional packages to be installed by apt after bootstrapping and after APT sources are set up.  This is useful for packages with pre-depends, which debootstrap do not handle well.

---

#### General system settings:

##### `SET_ARCH`
|value|integer`
|default:*32*
|format:** `[ 32 | 64 ]`
|description:** Set Architecture to default 32bit. If you want to compile 64-bit (RPI3/RPI3+/RPI4) set it to `64`. This option will set every needed cross-compiler or board specific option for a successful build.

##### `RPI_MODEL`
|string|
|default:*2*
|format:** `[ 0 | 1 | 1P | 2 | 3 | 3P | 4 ]`
|description:** Set Architecture. This option will set most build options accordingly.
Specify the target Raspberry Pi hardware model. The script at this time supports the following Raspberry Pi models:
  *  `0`  = Raspberry Pi 0 and Raspberry Pi 0 W
  *  `1`  = Raspberry Pi 1 model A and B
  *  `1P` = Raspberry Pi 1 model B+ and A+
  *  `2`  = Raspberry Pi 2 model B
  *  `3`  = Raspberry Pi 3 model B
  *  `3P` = Raspberry Pi 3 model B+
  *  `4`  = Raspberry Pi 4 model B

##### `RELEASE`
|string|
|default:** "buster"
|format| [ jessie | buster | stretch | bullseye | testing | stable | oldstable ]`
|description:** Set the desired Debian release name. The script at this time supports the bootstrapping of the Debian releases `stretch` and `buster`.

##### `HOSTNAME`=""
|string|
|default:** "rpi$RPI_MODEL-$RELEASE" e.g. RPI3-buster
|format:**
|description:** Set system hostname. It's recommended that the hostname is unique in the corresponding subnet.

##### `DEFLOCAL`
|string|
|default:** "en_US.UTF-8"
|format|Locale`
|description:** Set default system locale. This setting can also be changed inside the running OS using the `dpkg-reconfigure locales` command. Please note that on using this parameter the script will automatically install the required packages `locales`, `keyboard-configuration` and `console-setup`.

##### `TIMEZONE`=
|string|
|default:** "Europe/Berlin"
|format|Timezone`
|description:** Set default system timezone. All available timezones can be found in the `/usr/share/zoneinfo/` directory. This setting can also be changed inside the running OS using the `dpkg-reconfigure tzdata` command.

##### `EXPANDROOT`=true
Expand the root partition and filesystem automatically on first boot.

---

#### User settings:

##### `ENABLE_ROOT`
*  **value:** `[ true | false ]`
*  **true|Enable root login if ROOT_PASSWORD is set`
*  **false|Disable root login`
*  **default:** false
|description:** Set root user password so root login will be enabled

##### `ROOT_PASSWORD`
|string|
|default:** "raspberry"
|format:** ``
|description:** Set system `root` password. It's **STRONGLY** recommended that you choose a custom password.

##### `ENABLE_USER`
*  **value:** `[ true | false ]`
*  **true|Create user`
*  **false|Create no user`
*  **default|true`
|description:** Create non-root user with password `USER_PASSWORD`=raspberry. Unless overridden with `USER_NAME`=user, the username will be `pi`.

##### `USER_NAME`
|string|
|default:** "pi"
|format:** 
|description:** Non-root user to create.  Ignored if `ENABLE_USER`=false

##### `USER_PASSWORD`
|string|
|default:** "raspberry"
|format:** 
|description:** 
Set password for the created non-root user `USER_NAME`=pi. Ignored if `ENABLE_USER`=false. It's **STRONGLY** recommended that you choose a custom password.


---

#### Keyboard settings:
|string|
|default|
|format|
|description:** 
These options are used to configure keyboard layout in `/etc/default/keyboard` for console and Xorg. These settings can also be changed inside the running OS using the `dpkg-reconfigure keyboard-configuration` command.

##### `XKB_MODEL`
|string|
|default|
|format|
|description:** 
Set the name of the model of your keyboard type.

##### `XKB_LAYOUT`
|string|
|default|
|format|
|description:** 
Set the supported keyboard layout(s).

##### `XKB_VARIANT`
|string|
|default|
|format|
|description:** 
Set the supported variant(s) of the keyboard layout(s).

##### `XKB_OPTIONS`
|string|
|default|
|format|
|description:** 
Set extra xkb configuration options.

---

#### Networking settings:

##### `ENABLE_IPV6`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable IPv6 support. The network interface configuration is managed via systemd-networkd.

##### `ENABLE_WIRELESS`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Download and install the [closed-source firmware binary blob](https://github.com/RPi-Distro/firmware-nonfree/raw/master/brcm) that is required to run the internal wireless interface of the Raspberry Pi model `3`. This parameter is ignored if the specified `RPI_MODEL` is not `0`,`3`,`3P`,`4`.

##### `ENABLE_IPTABLES`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable iptables IPv4/IPv6 firewall. Simplified ruleset: Allow all outgoing connections. Block all incoming connections except to OpenSSH service.

##### `ENABLE_HARDNET`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable IPv4/IPv6 network stack hardening settings.

##### `ENABLE_IFNAMES`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable automatic assignment of predictable, stable network interface names for all NICs. TRUE=creates complex and long interface names like e.g. encx8945924.

---

#### Networking settings (DHCP):
This parameter `ENABLE_ETH_DHCP` is used to set up networking auto-configuration in `/etc/systemd/network/eth0.network`. This parameter `ENABLE_WIFI_DHCP` is used to set up networking auto-configuration in `/etc/systemd/network/wlan0.network`. The default location of network configuration files in the Debian `stretch` release was changed to `/lib/systemd/network`.`

##### `ENABLE_ETH_DHCP`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Set the system to use DHCP. This requires an DHCP server.

##### `ENABLE_WIFI_DHCP`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Set the system to use DHCP. This requires an DHCP server. Requires ENABLE_WIRELESS

---

#### Networking settings (ethernet static):
These parameters are used to set up a static networking configuration in `/etc/systemd/network/eth0.network`. The following static networking parameters are only supported if `ENABLE_ETH_DHCP` was set to `false`. The default location of network configuration files in the Debian `stretch` release was changed to `/lib/systemd/network`.

##### `NET_ETH_ADDRESS`
|string|
|default|
|format|
|description:** 
Set a static IPv4 or IPv6 address and its prefix, separated by "/", eg. "192.169.0.3/24".

##### `NET_ETH_GATEWAY`
|string|
|default|
|format|
|description:** 
Set the IP address for the default gateway.

##### `NET_ETH_DNS_1`
|string|
|default|
|format|
|description:** 
Set the IP address for the first DNS server.

##### `NET_ETH_DNS_2`
|string|
|default|
|format|
|description:** 
Set the IP address for the second DNS server.

##### `NET_ETH_DNS_DOMAINS`
|string|
|default|
|format|
|description:** 
Set the default DNS search domains to use for non fully qualified hostnames.

##### `NET_ETH_NTP_1`
|string|
|default|
|format|
|description:** 
Set the IP address for the first NTP server.

##### `NET_ETH_NTP_2`
|string|
|default|
|format|
|description:** 
Set the IP address for the second NTP server.

---

#### Networking settings (WIFI):

##### `NET_WIFI_SSID`
|string|
|default|
|format|
|description:** 
Set to your WIFI SSID

##### `NET_WIFI_PSK`
|string|
|default|
|format|
|description:** 
Set your WPA/WPA2 PSK

---

#### Networking settings (WIFI static):
These parameters are used to set up a static networking configuration in `/etc/systemd/network/wlan0.network`. The following static networking parameters are only supported if `ENABLE_WIFI_DHCP` was set to `false`. The default location of network configuration files in the Debian `stretch` release was changed to `/lib/systemd/network`.

##### `NET_WIFI_ADDRESS`
|string|
|default|
|format|
|description:** 
Set a static IPv4 or IPv6 address and its prefix, separated by "/", eg. "192.169.0.3/24".

##### `NET_WIFI_GATEWAY`
|string|
|default|
|format|
|description:** 
Set the IP address for the default gateway.

##### `NET_WIFI_DNS_1`
|string|
|default|
|format|
|description:** 
Set the IP address for the first DNS server.

##### `NET_WIFI_DNS_2`
|string|
|default|
|format|
|description:** 
Set the IP address for the second DNS server.

##### `NET_WIFI_DNS_DOMAINS`
|string|
|default|
|format|
|description:** 
Set the default DNS search domains to use for non fully qualified hostnames.

##### `NET_WIFI_NTP_1`
|string|
|default|
|format|
|description:** 
Set the IP address for the first NTP server.

##### `NET_WIFI_NTP_2`
|string|
|default|
|format|
|description:** 
Set the IP address for the second NTP server.

---

#### Basic system features:

##### `ENABLE_CONSOLE`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable serial console interface. Recommended if no monitor or keyboard is connected to the RPi2/3. In case of problems fe. if the network (auto) configuration failed - the serial console can be used to access the system. On RPI `0` `3` `3P` the CPU speed is locked at lowest speed.

##### `ENABLE_PRINTK`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enables printing kernel messages to konsole. printk is `3 4 1 3` as in raspbian.

##### `ENABLE_BLUETOOTH`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable onboard Bluetooth interface on the RPi0/3/3P. See: [Configuring the GPIO serial port on Raspbian jessie and stretch](https://spellfoundry.com/2016/05/29/configuring-gpio-serial-port-raspbian-jessie-including-pi-3/).

##### `ENABLE_MINIUART_OVERLAY`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Bluetooth to use this. Adds overlay to swap UART0 with UART1. Enabling (slower) Bluetooth and full speed serial console. - RPI `0` `3` `3P` have a fast `hardware UART0` (ttyAMA0) and a `mini UART1` (ttyS0)! RPI `1` `1P` `2` only have a `hardware UART0`. `UART0` is considered better, because is faster and more stable than `mini UART1`. By default the Bluetooth modem is mapped to the `hardware UART0` and `mini UART` is used for console. The `mini UART` is a problem for the serial console, because its baudrate depends on the CPU frequency, which is changing on runtime. Resulting in a volatile baudrate and thus in an unusable serial console.
 
##### `ENABLE_TURBO`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Turbo mode. This setting locks cpu at the highest frequency. As setting ENABLE_CONSOLE=true locks RPI to lowest CPU speed, this is can be used additionally to lock cpu hat max speed. Need a good power supply and probably cooling for the Raspberry PI.

##### `ENABLE_I2C`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable I2C interface on the RPi 0/1/2/3. Please check the [RPi 0/1/2/3 pinout diagrams](https://elinux.org/RPi_Low-level_peripherals) to connect the right GPIO pins.

##### `ENABLE_SPI`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable SPI interface on the RPi 0/1/2/3. Please check the [RPi 0/1/2/3 pinout diagrams](https://elinux.org/RPi_Low-level_peripherals) to connect the right GPIO pins.

##### `ENABLE_SSHD`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install and enable OpenSSH service. The default configuration of the service doesn't allow `root` to login. Please use the user `pi` instead and `su -` or `sudo` to execute commands as root.

##### `ENABLE_NONFREE`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable non-free packages in sources.list

##### `ENABLE_RSYSLOG`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
If set to false, disable and uninstall rsyslog (so logs will be available only in journal files)

##### `ENABLE_SOUND`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable sound hardware and install Advanced Linux Sound Architecture.

##### `ENABLE_HWRANDOM`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Hardware Random Number Generator. Strong random numbers are important for most network-based communications that use encryption. It's recommended to be enabled.

##### `ENABLE_MINGPU`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Minimize the amount of shared memory reserved for the GPU. It doesn't seem to be possible to fully disable the GPU.

##### `ENABLE_XORG`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install Xorg open-source X Window System.

##### `ENABLE_WM`=""
Install a user-defined window manager for the X Window System. To make sure all X related package dependencies are getting installed `ENABLE_XORG` will automatically get enabled if `ENABLE_WM` is used. The `rpi23-gen-image.sh` script has been tested with the following list of window managers: `blackbox`, `openbox`, `fluxbox`, `jwm`, `dwm`, `xfce4`, `awesome`.

##### `ENABLE_SYSVINIT`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Support for halt,init,poweroff,reboot,runlevel,shutdown,init commands

##### `ENABLE_SPLASH`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable default Raspberry Pi boot up rainbow splash screen.

##### `ENABLE_LOGO`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable default Raspberry Pi console logo (image of four raspberries in the top left corner).

##### `ENABLE_SILENT_BOOT`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Set the verbosity of console messages shown during boot up to a strict minimum.

##### `DISABLE_UNDERVOLT_WARNINGS`=
|value|integer`
|default|
|format:** `[ 1 | 2 ]`
|description:** 
Disable RPi2/3 under-voltage warnings and overlays. Setting the parameter to `1` will disable the warning overlay. Setting it to `2` will additionally allow RPi2/3 turbo mode when low-voltage is present.

---

#### Advanced system features:

##### `ENABLE_DPHYSSWAP`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable swap. The size of the swapfile is chosen relative to the size of the root partition. It'll use the `dphys-swapfile` package for that.

##### `ENABLE_SYSTEMDSWAP`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enables [Systemd-swap service](https://github.com/Nefelim4ag/systemd-swap). Usefull if `KERNEL_ZSWAP` is enabled.

##### `ENABLE_QEMU`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Generate kernel (`vexpress_defconfig`), file system image (`qcow2`) and DTB files that can be used for QEMU full system emulation (`vexpress-A15`). The output files are stored in the `$(pwd)/images/qemu` directory. You can find more information about running the generated image in the QEMU section of this readme file.

##### `QEMU_BINARY`
|string|
|default|
|format|
|description:** 
Sets the QEMU enviornment for the Debian archive. Set by RPI_MODEL

##### `ENABLE_KEYGEN`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Recover your lost codec license

##### `ENABLE_MINBASE`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Use debootstrap script variant `minbase` which only includes essential packages and apt. This will reduce the disk usage by about 65 MB.

##### `ENABLE_UBOOT`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Replace the default RPi 0/1/2/3 second stage bootloader (bootcode.bin) with [U-Boot bootloader](https://git.denx.de/?p=u-boot.git;a=summary). U-Boot can boot images via the network using the BOOTP/TFTP protocol.
RPI4 needs tbd

##### `UBOOTSRC_DIR`
|string|
|default|
|format|
|description:** 
Path to a directory (`u-boot`) of [U-Boot bootloader sources](https://git.denx.de/?p=u-boot.git;a=summary) that will be copied, configured, build and installed inside the chroot.

##### `ENABLE_FBTURBO`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install and enable the [hardware accelerated Xorg video driver](https://github.com/ssvb/xf86-video-fbturbo) `fbturbo`. Please note that this driver is currently limited to hardware accelerated window moving and scrolling.

##### `FBTURBOSRC_DIR`
|string|
|default|
|format|
|description:** 
Path to a directory (`xf86-video-fbturbo`) of [hardware accelerated Xorg video driver sources](https://github.com/ssvb/xf86-video-fbturbo) that will be copied, configured, build and installed inside the chroot.

##### `ENABLE_VIDEOCORE`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install and enable the [ARM side libraries for interfacing to Raspberry Pi GPU](https://github.com/raspberrypi/userland) `vcgencmd`. Please note that this driver is currently limited to hardware accelerated window moving and scrolling.

##### `VIDEOCORESRC_DIR`
|string|
|default|
|format|
|description:** 
Path to a directory (`userland`) of [ARM side libraries for interfacing to Raspberry Pi GPU](https://github.com/raspberrypi/userland) that will be copied, configured, build and installed inside the chroot.

##### `ENABLE_NEXMON`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install and enable the [Source code for a C-based firmware patching framework for Broadcom/Cypress WiFi chips that enables you to write your own firmware patches, for example, to enable monitor mode with radiotap headers and frame injection](https://github.com/seemoo-lab/nexmon.git).

##### `NEXMONSRC_DIR`
|string|
|default|
|format|
|description:** 
Path to a directory (`nexmon`) of [Source code for ARM side libraries for interfacing to Raspberry Pi GPU](https://github.com/raspberrypi/userland) that will be copied, configured, build and installed inside the chroot.

##### `ENABLE_SPLITFS`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable having root partition on an USB drive by creating two image files: one for the `/boot/firmware` mount point, and another for `/`.

##### `CHROOT_SCRIPTS`
|string|
|default|
|format|
|description:** 
Path to a directory with scripts that should be run in the chroot before the image is finally built. Every executable file in this directory is run in lexicographical order.

##### `ENABLE_INITRAMFS`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Create an initramfs that that will be loaded during the Linux startup process. `ENABLE_INITRAMFS` will automatically get enabled if `ENABLE_CRYPTFS`=true. This parameter will be ignored if `BUILD_KERNEL`=false.

##### `ENABLE_DBUS`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install and enable D-Bus message bus. Please note that systemd should work without D-bus but it's recommended to be enabled.

---

#### SSH settings:

##### `SSH_ENABLE_ROOT`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable password-based root login via SSH. This may be a security risk with the default password set, use only in trusted environments. `ENABLE_ROOT` must be set to `true`.

##### `SSH_DISABLE_PASSWORD_AUTH`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Disable password-based SSH authentication. Only public key based SSH (v2) authentication will be supported.

##### `SSH_LIMIT_USERS`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Limit the users that are allowed to login via SSH. Only allow user `USER_NAME`=pi and root if `SSH_ENABLE_ROOT`=true to login. This parameter will be ignored if `dropbear` SSH is used (`REDUCE_SSHD`=true).

##### `SSH_ROOT_PUB_KEY`
|string|
|default|
|format|
|description:** 
Use full path to file. Add SSH (v2) public key(s) from specified file to `authorized_keys` file to enable public key based SSH (v2) authentication of user `root`. The specified file can also contain multiple SSH (v2) public keys. SSH protocol version 1 is not supported. `ENABLE_ROOT` **and** `SSH_ENABLE_ROOT` must be set to `true`.

##### `SSH_USER_PUB_KEY`
|string|
|default|
|format|
|description:** 
Use full path to file. Add SSH (v2) public key(s) from specified file to `authorized_keys` file to enable public key based SSH (v2) authentication of user `USER_NAME`=pi. The specified file can also contain multiple SSH (v2) public keys. SSH protocol version 1 is not supported.

---

#### Kernel settings:

##### `BUILD_KERNEL`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Build and install the latest RPi 0/1/2/3/4 Linux kernel. The default RPi 0/1/2/3/ kernel configuration is used most of the time. 
ENABLE_NEXMON - Changes Kernel Source to [https://github.com/Re4son/](Kali Linux Kernel)
Precompiled 32bit kernel for RPI0/1/2/3 by [https://github.com/hypriot/](hypriot)
Precompiled 64bit kernel for RPI3/4 by [https://github.com/sakaki-/](sakaki)

##### `CROSS_COMPILE`
|string|
|default|
|format|
|description:** 
This sets the cross-compile environment for the compiler. Set by RPI_MODEL

##### `KERNEL_ARCH`
|string|
|default|
|format|
|description:** 
This sets the kernel architecture for the compiler. Set by RPI_MODEL

##### `KERNEL_IMAGE`
|string|
|default|
|format|
|description:** 
Name of the image file in the boot partition. Set by RPI_MODEL

##### `KERNEL_BRANCH`
|string|
|default|
|format|
|description:** 
Name of the requested branch from the GIT location for the RPi Kernel. Default is using the current default branch from the GIT site.

##### `KERNEL_DEFCONFIG`
|string|
|default|
|format|
|description:** 
Sets the default config for kernel compiling. Set by RPI_MODEL

##### `KERNEL_REDUCE`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Reduce the size of the generated kernel by removing unwanted devices, network and filesystem drivers (experimental).

##### `KERNEL_THREADS`=
*  **value|integer`
*  **default:** 
*  **format:** [ nothing | DesiredCoreCount ]
|description:** Number of threads to build the kernel. If not set, the script will automatically determine the maximum number of CPU cores to speed up kernel compilation.

##### `KERNEL_HEADERS`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Install kernel headers with the built kernel.

##### `KERNEL_MENUCONFIG`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Start `make menuconfig` interactive menu-driven kernel configuration. The script will continue after `make menuconfig` was terminated.

##### `KERNEL_OLDDEFCONFIG`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Run `make olddefconfig` to automatically set all new kernel configuration options to their recommended default values.

##### `KERNEL_CCACHE`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Compile the kernel using ccache. This speeds up kernel recompilation by caching previous compilations and detecting when the same compilation is being done again.

##### `KERNEL_REMOVESRC`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Remove all kernel sources from the generated OS image after it was built and installed.

##### `KERNELSRC_DIR`
|string|
|default|
|format|
|description:** 
Path to a directory (`linux`) of [RaspberryPi Linux kernel sources](https://github.com/raspberrypi/linux) that will be copied, configured, build and installed inside the chroot.

##### `KERNELSRC_CLEAN`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Clean the existing kernel sources directory `KERNELSRC_DIR` (using `make mrproper`) after it was copied to the chroot and before the compilation of the kernel has started. This parameter will be ignored if no `KERNELSRC_DIR` was specified or if `KERNELSRC_PREBUILT`=true.

##### `KERNELSRC_CONFIG`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Run `make bcm2709_defconfig` (and optional `make menuconfig`) to configure the kernel sources before building. This parameter is automatically set to `true` if no existing kernel sources directory was specified using `KERNELSRC_DIR`. This parameter is ignored if `KERNELSRC_PREBUILT`=true.

##### `KERNELSRC_USRCONFIG`
|string|
|default|
|format|
|description:** 
Copy own config file to kernel `.config`. If `KERNEL_MENUCONFIG`=true then running after copy.

##### `KERNELSRC_PREBUILT`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
With this parameter set to true the script expects the existing kernel sources directory to be already successfully cross-compiled. The parameters `KERNELSRC_CLEAN`, `KERNELSRC_CONFIG`, `KERNELSRC_USRCONFIG` and `KERNEL_MENUCONFIG` are ignored and no kernel compilation tasks are performed.

##### `RPI_FIRMWARE_DIR`
|string|
|default|
|format|
|description:** 
The directory (`firmware`) containing a local copy of the firmware from the [RaspberryPi firmware project](https://github.com/raspberrypi/firmware). Default is to download the latest firmware directly from the project.

##### `KERNEL_DEFAULT_GOV`="ONDEMAND"
|string|
|default|
|format|
|description:** 
Set the default cpu governor at kernel compilation. Supported values are: PERFORMANCE POWERSAVE USERSPACE ONDEMAND CONSERVATIVE SCHEDUTIL

##### `KERNEL_NF`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Netfilter modules as kernel modules. You want that for iptables.

##### `KERNEL_VIRT`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Kernel KVM support (/dev/kvm)

##### `KERNEL_ZSWAP`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Kernel Zswap support. Best use on high RAM load and mediocre CPU load usecases

##### `KERNEL_BPF`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Allow attaching eBPF programs to a cgroup using the bpf syscall (CONFIG_BPF_SYSCALL CONFIG_CGROUP_BPF) [systemd wants it - File /lib/systemd/system/systemd-journald.server:36 configures an IP firewall (IPAddressDeny=all), but the local system does not support BPF/cgroup based firewalls]

##### `KERNEL_SECURITY`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enables Apparmor, integrity subsystem, auditing.

##### `KERNEL_BTRFS`="false"
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
enable btrfs kernel support

##### `KERNEL_POEHAT`="false"
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
enable Enable RPI POE HAT fan kernel support

##### `KERNEL_NSPAWN`="false"
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable per-interface network priority control - for systemd-nspawn

##### `KERNEL_DHKEY`="true"
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Diffie-Hellman operations on retained keys - required for >keyutils-1.6

---

#### Reduce disk usage:
The following list of parameters is ignored if `ENABLE_REDUCE`=false.

##### `ENABLE_REDUCE`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Reduce the disk space usage by deleting packages and files. See `REDUCE_*` parameters for detailed information.

##### `REDUCE_APT`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Configure APT to use compressed package repository lists and no package caching files.

##### `REDUCE_DOC`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Remove all doc files (harsh). Configure APT to not include doc files on future `apt-get` package installations.

##### `REDUCE_MAN`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Remove all man pages and info files (harsh).  Configure APT to not include man pages on future `apt-get` package installations.

##### `REDUCE_VIM`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Replace `vim-tiny` package by `levee` a tiny vim clone.

##### `REDUCE_BASH`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Remove `bash` package and switch to `dash` shell (experimental).

##### `REDUCE_HWDB`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Remove PCI related hwdb files (experimental).

##### `REDUCE_SSHD`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Replace `openssh-server` with `dropbear`.

##### `REDUCE_LOCALE`=true
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Remove all `locale` translation files.

---

#### Encrypted root partition:
# On first boot, you will be asked to enter you password several time

##### `ENABLE_CRYPTFS`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable full system encryption with dm-crypt. Setup a fully LUKS encrypted root partition (aes-xts-plain64:sha512) and generate required initramfs. The /boot directory will not be encrypted. This parameter will be ignored if `BUILD_KERNEL`=false. `ENABLE_CRYPTFS` is experimental. SSH-to-initramfs is currently not supported but will be soon - feel free to help.

##### `CRYPTFS_PASSWORD`=""
|string|
|default|
|format|
|description:** 
Set password of the encrypted root partition. This parameter is mandatory if `ENABLE_CRYPTFS`=true.

##### `CRYPTFS_MAPPING`="secure"
|string|
|default|
|format|
|description:** 
Set name of dm-crypt managed device-mapper mapping.

##### `CRYPTFS_CIPHER`="aes-xts-plain64"
|string|
|default|
|format|
|description:** 
Set cipher specification string. `aes-xts*` ciphers are strongly recommended.

##### `CRYPTFS_HASH`=sha256
|string|
|default|
|format|
|description:** 
Hash function and size to be used

##### `CRYPTFS_XTSKEYSIZE`=256
*  **value|integer`
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Sets key size in bits. The argument has to be a multiple of 8.

##### `CRYPTFS_DROPBEAR`=false
*  **value:** ``
*  **true:** ``
*  **false:** ``
*  **default:** ``
|description:** 
Enable Dropbear Initramfs support

##### `CRYPTFS_DROPBEAR_PUBKEY`=""
|string|
|default|
|format|
|description:** 
Provide path to dropbear Public RSA-OpenSSH Key

---

#### Build settings:

##### `BASEDIR`="$(pwd)/images/${RELEASE}"
|string|
|default|
|format|
|description:** 
Set a path to a working directory used by the script to generate an image.

##### `IMAGE_NAME`="${BASEDIR}/${DATE}-${KERNEL_ARCH}-${KERNEL_BRANCH}-rpi${RPI_MODEL}-${RELEASE}-${RELEASE_ARCH}"
|string|
|default|
|format|
|description:** 
Set a filename for the output file(s). Note: the script will create $IMAGE_NAME.img if `ENABLE_SPLITFS`=false or $IMAGE_NAME-frmw.img and $IMAGE_NAME-root.img if `ENABLE_SPLITFS`=true. Note 2: If the KERNEL_BRANCH is not set, the word "CURRENT" is used.

## Understanding the script
The functions of this script that are required for the different stages of the bootstrapping are split up into single files located inside the `bootstrap.d` directory. During the bootstrapping every script in this directory gets executed in lexicographical order:

| Script | Description |
| --- | --- |
| `10-bootstrap.sh` | Debootstrap basic system |
| `11-apt.sh` | Setup APT repositories |
| `12-locale.sh` | Setup Locales and keyboard settings |
| `13-kernel.sh` | Build and install RPi 0/1/2/3 Kernel |
| `14-fstab.sh` | Setup fstab and initramfs |
| `15-rpi-config.sh` | Setup RPi 0/1/2/3 config and cmdline |
| `20-networking.sh` | Setup Networking |
| `21-firewall.sh` | Setup Firewall |
| `30-security.sh` | Setup Users and Security settings |
| `31-logging.sh` | Setup Logging |
| `32-sshd.sh` | Setup SSH and public keys |
| `41-uboot.sh` | Build and Setup U-Boot |
| `42-fbturbo.sh` | Build and Setup fbturbo Xorg driver |
| `43-videocore.sh` | Build and Setup videocore libraries |
| `50-firstboot.sh` | First boot actions |
| `99-reduce.sh` | Reduce the disk space usage |

All the required configuration files that will be copied to the generated OS image are located inside the `files` directory. It is not recommended to modify these configuration files manually.

| Directory | Description |
| --- | --- |
| `apt` | APT management configuration files |
| `boot` | Boot and RPi 0/1/2/3 configuration files |
| `dpkg` | Package Manager configuration |
| `etc` | Configuration files and rc scripts |
| `firstboot` | Scripts that get executed on first boot  |
| `initramfs` | Initramfs scripts |
| `iptables` | Firewall configuration files |
| `locales` | Locales configuration |
| `modules` | Kernel Modules configuration |
| `mount` | Fstab configuration |
| `network` | Networking configuration files |
| `sysctl.d` | Swapping and Network Hardening configuration |
| `xorg` | fbturbo Xorg driver configuration |

## Custom packages and scripts
Debian custom packages, i.e. those not in the debian repositories, can be installed by placing them in the `packages` directory. They are installed immediately after packages from the repositories are installed. Any dependencies listed in the custom packages will be downloaded automatically from the repositories. Do not list these custom packages in `APT_INCLUDES`.

Scripts in the custom.d directory will be executed after all other installation is complete but before the image is created.

## Logging of the bootstrapping process
All information related to the bootstrapping process and the commands executed by the `rpi23-gen-image.sh` script can easily be saved into a logfile. The common shell command `script` can be used for this purpose:

```shell
script -c 'APT_SERVER=ftp.de.debian.org ./rpi23-gen-image.sh' ./build.log
```

## Flashing the image file
After the image file was successfully created by the `rpi23-gen-image.sh` script it can be copied to the microSD card that will be used by the RPi 0/1/2/3 computer. This can be performed by using the tools `bmaptool` or `dd`. Using `bmaptool` will probably speed-up the copy process because `bmaptool` copies more wisely than `dd`.

##### Flashing examples:
```shell
bmaptool copy ./images/buster/2017-01-23-rpi3-buster.img /dev/mmcblk0
dd bs=4M if=./images/buster/2017-01-23-rpi3-buster.img of=/dev/mmcblk0
```
If you have set `ENABLE_SPLITFS`, copy the `-frmw` image on the microSD card, then the `-root` one on the USB drive:
```shell
bmaptool copy ./images/buster/2017-01-23-rpi3-buster-frmw.img /dev/mmcblk0
bmaptool copy ./images/buster/2017-01-23-rpi3-buster-root.img /dev/sdc
```

## QEMU emulation
Start QEMU full system emulation:
```shell
qemu-system-arm -m 2048M -M vexpress-a15 -cpu cortex-a15 -kernel kernel7.img -no-reboot -dtb vexpress-v2p-ca15_a7.dtb -sd ${IMAGE_NAME}.qcow2 -append "root=/dev/mmcblk0p2 rw rootfstype=ext4 console=tty1"
```

Start QEMU full system emulation and output to console:
```shell
qemu-system-arm -m 2048M -M vexpress-a15 -cpu cortex-a15 -kernel kernel7.img -no-reboot -dtb vexpress-v2p-ca15_a7.dtb -sd ${IMAGE_NAME}.qcow2 -append "root=/dev/mmcblk0p2 rw rootfstype=ext4 console=ttyAMA0,115200 init=/bin/systemd" -serial stdio
```

Start QEMU full system emulation with SMP and output to console:
```shell
qemu-system-arm -m 2048M -M vexpress-a15 -cpu cortex-a15 -smp cpus=2,maxcpus=2 -kernel kernel7.img -no-reboot -dtb vexpress-v2p-ca15_a7.dtb -sd ${IMAGE_NAME}.qcow2 -append "root=/dev/mmcblk0p2 rw rootfstype=ext4 console=ttyAMA0,115200 init=/bin/systemd" -serial stdio
```

Start QEMU full system emulation with cryptfs, initramfs and output to console:
```shell
qemu-system-arm -m 2048M -M vexpress-a15 -cpu cortex-a15 -kernel kernel7.img -no-reboot -dtb vexpress-v2p-ca15_a7.dtb -sd ${IMAGE_NAME}.qcow2 -initrd "initramfs-${KERNEL_VERSION}" -append "root=/dev/mapper/secure cryptdevice=/dev/mmcblk0p2:secure rw rootfstype=ext4 console=ttyAMA0,115200 init=/bin/systemd" -serial stdio
```

## External links and references
* [Debian worldwide mirror sites](https://www.debian.org/mirror/list)
* [Debian Raspberry Pi 2 Wiki](https://wiki.debian.org/RaspberryPi2)
* [Debian CrossToolchains Wiki](https://wiki.debian.org/CrossToolchains)
* [Official Raspberry Pi Firmware on github](https://github.com/raspberrypi/firmware)
* [Official Raspberry Pi Kernel on github](https://github.com/raspberrypi/linux)
* [U-BOOT git repository](https://git.denx.de/?p=u-boot.git;a=summary)
* [Xorg DDX driver fbturbo](https://github.com/ssvb/xf86-video-fbturbo)
* [RPi3 Wireless interface firmware](https://github.com/RPi-Distro/firmware-nonfree/tree/master/brcm)
* [Collabora RPi2 Kernel precompiled](https://repositories.collabora.co.uk/debian/)
