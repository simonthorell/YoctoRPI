# https://docs.yoctoproject.org/kernel-dev/common.html#creating-configuration-fragments
# bitbake linux-yocto -c kernel_configcheck -f

FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# https://github.com/bluez/bluez/wiki/test%E2%80%90runner
SRC_URI += "file://bluez.cfg"