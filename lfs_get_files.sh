export LFS=/mnt/lfs

mkdir -pv $LFS
mount -v -t ext4 /dev/sda2 $LFS
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html
cd $LFS/sources
wget http://www.linuxfromscratch.org/lfs/view/stable/wget-list

wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

pushd $LFS/sources
md5sum -c md5sums
popd

md5sum -c md5sums |grep FAILED

