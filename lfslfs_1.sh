$ sudo su -

#apt -y install screen
#apt -y install ssh

$sudo apt -y install screen ssh

$sudo passwd xubuntu
$sudo service ssh start


cat > version-check.sh << "EOF"
#!/bin/bash
# Simple script to list version numbers of critical development tools
export LC_ALL=C
bash --version | head -n1 | cut -d" " -f2-4
MYSH=$(readlink -f /bin/sh)
echo "/bin/sh -> $MYSH"
echo $MYSH | grep -q bash || echo "ERROR: /bin/sh does not point to bash"
unset MYSH
echo -n "Binutils: "; ld --version | head -n1 | cut -d" " -f3-
bison --version | head -n1
if [ -h /usr/bin/yacc ]; then
  echo "/usr/bin/yacc -> `readlink -f /usr/bin/yacc`";
elif [ -x /usr/bin/yacc ]; then
  echo yacc is `/usr/bin/yacc --version | head -n1`
else
  echo "yacc not found" 
fi
bzip2 --version 2>&1 < /dev/null | head -n1 | cut -d" " -f1,6-
echo -n "Coreutils: "; chown --version | head -n1 | cut -d")" -f2
diff --version | head -n1
find --version | head -n1
gawk --version | head -n1
if [ -h /usr/bin/awk ]; then
  echo "/usr/bin/awk -> `readlink -f /usr/bin/awk`";
elif [ -x /usr/bin/awk ]; then
  echo awk is `/usr/bin/awk --version | head -n1`
else 
  echo "awk not found" 
fi
gcc --version | head -n1
g++ --version | head -n1
ldd --version | head -n1 | cut -d" " -f2-  # glibc version
grep --version | head -n1
gzip --version | head -n1
cat /proc/version
m4 --version | head -n1
make --version | head -n1
patch --version | head -n1
echo Perl `perl -V:version`
sed --version | head -n1
tar --version | head -n1
makeinfo --version | head -n1
xz --version | head -n1
echo 'int main(){}' > dummy.c && g++ -o dummy dummy.c
if [ -x dummy ]
  then echo "g++ compilation OK";
  else echo "g++ compilation failed"; fi
rm -f dummy.c dummy
EOF
bash version-check.sh



bash version-check.sh | grep not

sudo dpkg-reconfigure dash
apt -y install bison
apt -y install gcc
apt -y install g++
apt -y install m4
apt -y install make
apt -y install makeinfo
apt -y install texinfo

apt -y install gawk
apt -y install bison
apt -y install automake

# vi mydeps.sh ....


# export LFS=/mnt/lfs

mkdir -pv $LFS
mount -v -t ext4 /dev/sda2 $LFS
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

# http://www.linuxfromscratch.org/lfs/view/stable/chapter03/introduction.html
$ cd $LFS/sources
$ wget http://www.linuxfromscratch.org/lfs/view/stable/wget-list

$ wget --input-file=wget-list --continue --directory-prefix=$LFS/sources

pushd $LFS/sources
md5sum -c md5sums
popd

md5sum -c md5sums |grep FAILED

mkdir -v $LFS/tools
ln -sv $LFS/tools /

groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs

passwd lfs
chown -v lfs $LFS/tools
chown -v lfs $LFS/sources
su - lfs

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
EOF

source ~/.bash_profile

# http://www.linuxfromscratch.org/lfs/view/stable/chapter05/generalinstructions.html
echo $LFS

apt -y install gawk
apt -y install bison
apt -y install automake


# apt -y install gawk bison automake

