# http://linuxfromscratch.org/lfs/view/stable/chapter04/creatingtoolsdir.html
mkdir -v $LFS/tools
ln -sv $LFS/tools /

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

chown -v lfs $LFS/tools
chown -v lfs $LFS/sources

echo "Please enter the password for the lfs user."
passwd lfs
su - lfs
