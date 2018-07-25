
cd /sources
tar -xf linux-4.15.3.tar.xz
cd linux-4.15.3

make mrproper
make defconfig
make menuconfig
make
make modules_install

# OUTSIDE FROM CHROOT
mount --bind /boot /mnt/lfs/boot

cp -iv arch/x86/boot/bzImage /boot/vmlinuz-4.15.3-lfs-8.2
cp -iv System.map /boot/System.map-4.15.3
install -d /usr/share/doc/linux-4.15.3
cp -r Documentation/* /usr/share/doc/linux-4.15.3

install -v -m755 -d /etc/modprobe.d
cat > /etc/modprobe.d/usb.conf << "EOF"
# Begin /etc/modprobe.d/usb.conf

install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF

cd ../
rm -R -f Linux-4.15.3


grub-install /dev/sda

cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
set default=0
set timeout=5

insmod ext2
set root=(hd0,1)

menuentry "GNU/Linux, Linux 4.15.3-lfs-8.2" {
        linux   /boot/vmlinuz-4.15.3-lfs-8.2 root=/dev/sda2 ro
}
EOF

# http://linuxfromscratch.org/lfs/view/stable/chapter09/chapter09.html
# The End

echo 8.2 > /etc/lfs-release
cat > /etc/lsb-release << "EOF"
DISTRIB_ID="Linux From Scratch"
DISTRIB_RELEASE="8.2"
DISTRIB_CODENAME="Bernardino Lopez"
DISTRIB_DESCRIPTION="Linux From Scratch"
EOF

# http://linuxfromscratch.org/lfs/view/stable/chapter09/getcounted.html
# Get Counted

logout

umount -v $LFS/dev/pts
umount -v $LFS/dev
umount -v $LFS/run
umount -v $LFS/proc
umount -v $LFS/sys

umount -v $LFS

umount -v $LFS/usr
umount -v $LFS/home
umount -v $LFS

shutdown -r now
