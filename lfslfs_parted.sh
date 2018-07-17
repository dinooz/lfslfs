
parted --script /dev/sda \
    mklabel msdos \
    mkpart primary ext2 0 100MiB \
    mkpart primary ext4 100MiB -- -1s

mkfs -v -t ext2 /dev/sda1
mkfs -v -t ext4 /dev/sda2

export LFS=/mnt/lfs

mkdir -pv $LFS
mount -v -t ext4 /dev/sda2 $LFS

mkdir -v $LFS/sources

chmod -v a+wt $LFS/sources

