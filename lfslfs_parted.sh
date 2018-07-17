
parted --script /dev/sda \
    mklabel msdos \
    mkpart primary ext2 0 100MiB \
    mkpart primary ext4 100MiB -- -1s

mkfs -v -t ext2 /dev/sda1
mkfs -v -t ext4 /dev/sda2

