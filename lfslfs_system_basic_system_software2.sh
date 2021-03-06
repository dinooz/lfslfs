
#cd ../
cd /sources
rm -R -f bash-4.4.18
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: bash-4.4.18" >>~/slfs_basic_sys.log

tar -xf libtool-2.4.6.tar.xz
cd libtool-2.4.6

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f libtool-2.4.6
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: libtool-2.4.6" >>~/slfs_basic_sys.log

tar -xf gdbm-1.14.1.tar.gz
cd gdbm-1.14.1

./configure --prefix=/usr \
            --disable-static \
            --enable-libgdbm-compat

make
make check
make install

cd ../
rm -R -f gdbm-1.14.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: gdbm-1.14.1" >>~/slfs_basic_sys.log

tar -xf gperf-3.1.tar.gz
cd gperf-3.1

./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1
make
make -j1 check
make install

cd ../
rm -R -f gperf-3.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: gperf-3.1" >>~/slfs_basic_sys.log

tar -xf expat-2.2.5.tar.bz2
cd expat-2.2.5

sed -i 's|usr/bin/env |bin/|' run.sh.in
./configure --prefix=/usr --disable-static
make
make check
make install
install -v -dm755 /usr/share/doc/expat-2.2.5
install -v -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.5

cd ../
rm -R -f expat-2.2.5
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: expat-2.2.5" >>~/slfs_basic_sys.log

tar -xf inetutils-1.9.4.tar.xz
cd inetutils-1.9.4

./configure --prefix=/usr        \
            --localstatedir=/var \
            --disable-logger     \
            --disable-whois      \
            --disable-rcp        \
            --disable-rexec      \
            --disable-rlogin     \
            --disable-rsh        \
            --disable-servers

make
make check
make install

mv -v /usr/bin/{hostname,ping,ping6,traceroute} /bin
mv -v /usr/bin/ifconfig /sbin

cd ../
rm -R -f inetutils-1.9.4
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: inetutils-1.9.4" >>~/slfs_basic_sys.log

tar -xf perl-5.26.1.tar.xz
cd perl-5.26.1

echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
export BUILD_ZLIB=False
export BUILD_BZIP2=0

sh Configure -des -Dprefix=/usr                 \
                  -Dvendorprefix=/usr           \
                  -Dman1dir=/usr/share/man/man1 \
                  -Dman3dir=/usr/share/man/man3 \
                  -Dpager="/usr/bin/less -isR"  \
                  -Duseshrplib                  \
                  -Dusethreads

make
make -k test
make install
unset BUILD_ZLIB BUILD_BZIP2

cd ../
rm -R -f perl-5.26.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: perl-5.26.1" >>~/slfs_basic_sys.log

tar -xf XML-Parser-2.44.tar.gz
cd XML-Parser-2.44

perl Makefile.PL
make
make test
make install

cd ../
rm -R -f XML-Parser-2.44
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: XML-Parser-2.44" >>~/slfs_basic_sys.log

tar -xf intltool-0.51.0.tar.gz
cd intltool-0.51.0

sed -i 's:\\\${:\\\$\\{:' intltool-update.in
./configure --prefix=/usr
make
make check
make install
install -v -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO

cd ../
rm -R -f intltool-0.51.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: intltool-0.51.0" >>~/slfs_basic_sys.log

tar -xf autoconf-2.69.tar.xz
cd autoconf-2.69

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f autoconf-2.69
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: autoconf-2.69" >>~/slfs_basic_sys.log

tar -xf automake-1.15.1.tar.xz
cd automake-1.15.1

./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.15.1
make
sed -i "s:./configure:LEXLIB=/usr/lib/libfl.a &:" t/lex-{clean,depend}-cxx.sh
make -j4 check
make install

cd ../
rm -R -f automake-1.15.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: automake-1.15.1" >>~/slfs_basic_sys.log


tar -xf xz-5.2.3.tar.xz
cd xz-5.2.3

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/xz-5.2.3

make
make check
make install
mv -v   /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
mv -v /usr/lib/liblzma.so.* /lib
ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so

cd ../
rm -R -f xz-5.2.3
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: xz-5.2.3" >>~/slfs_basic_sys.log


tar -xf kmod-25.tar.xz
cd kmod-25

./configure --prefix=/usr          \
            --bindir=/bin          \
            --sysconfdir=/etc      \
            --with-rootlibdir=/lib \
            --with-xz              \
            --with-zlib
make
make install

for target in depmod insmod lsmod modinfo modprobe rmmod; do
  ln -sfv ../bin/kmod /sbin/$target
done

ln -sfv kmod /bin/lsmod

cd ../
rm -R -f kmod-25
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: kmod-25" >>~/slfs_basic_sys.log

tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1

sed -i '/^TESTS =/d' gettext-runtime/tests/Makefile.in &&
sed -i 's/test-lock..EXEEXT.//' gettext-tools/gnulib-tests/Makefile.in

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/gettext-0.19.8.1
make
make check
make install
chmod -v 0755 /usr/lib/preloadable_libintl.so

cd ../
rm -R -f gettext-0.19.8.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: gettext-0.19.8.1" >>~/slfs_basic_sys.log


tar -xf elfutils-0.170.tar.bz2
cd elfutils-0.170

./configure --prefix=/usr
make
make -C libelf install
install -vm644 config/libelf.pc /usr/lib/pkgconfig

cd ../
rm -R -f elfutils-0.170
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: elfutils-0.170" >>~/slfs_basic_sys.log


tar -xf libffi-3.2.1.tar.gz
cd libffi-3.2.1

sed -e '/^includesdir/ s/$(libdir).*$/$(includedir)/' \
    -i include/Makefile.in

sed -e '/^includedir/ s/=.*$/=@includedir@/' \
    -e 's/^Cflags: -I${includedir}/Cflags:/' \
    -i libffi.pc.in

./configure --prefix=/usr --disable-static
make
make check
make install

cd ../
rm -R -f libffi-3.2.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: libffi-3.2.1" >>~/slfs_basic_sys.log


tar -xf openssl-1.1.0g.tar.gz
cd openssl-1.1.0g

./config --prefix=/usr         \
         --openssldir=/etc/ssl \
         --libdir=lib          \
         shared                \
         zlib-dynamic

make
make test
sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
make MANSUFFIX=ssl install
mv -v /usr/share/doc/openssl /usr/share/doc/openssl-1.1.0g
cp -vfr doc/* /usr/share/doc/openssl-1.1.0g

cd ../
rm -R -f openssl-1.1.0g
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: openssl-1.1.0g" >>~/slfs_basic_sys.log


tar -xf Python-3.6.4.tar.xz
cd Python-3.6.4

./configure --prefix=/usr       \
            --enable-shared     \
            --with-system-expat \
            --with-system-ffi   \
            --with-ensurepip=yes
make
make install
chmod -v 755 /usr/lib/libpython3.6m.so
chmod -v 755 /usr/lib/libpython3.so

install -v -dm755 /usr/share/doc/python-3.6.4/html 

tar --strip-components=1  \
    --no-same-owner       \
    --no-same-permissions \
    -C /usr/share/doc/python-3.6.4/html \
    -xvf ../python-3.6.4-docs-html.tar.bz2

cd ../
rm -R -f Python-3.6.4
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: Python-3.6.4" >>~/slfs_basic_sys.log


tar -xf ninja-1.8.2.tar.gz
cd ninja-1.8.2

export NINJAJOBS=4
patch -Np1 -i ../ninja-1.8.2-add_NINJAJOBS_var-1.patch
python3 configure.py --bootstrap

python3 configure.py
./ninja ninja_test
./ninja_test --gtest_filter=-SubprocessTest.SetWithLots

install -vm755 ninja /usr/bin/
install -vDm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
install -vDm644 misc/zsh-completion  /usr/share/zsh/site-functions/_ninja

cd ../
rm -R -f ninja-1.8.2
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: ninja-1.8.2" >>~/slfs_basic_sys.log


tar -xf meson-0.44.0.tar.gz
cd meson-0.44.0

python3 setup.py build
python3 setup.py install

cd ../
rm -R -f meson-0.44.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: meson-0.44.0" >>~/slfs_basic_sys.log


tar -xf procps-ng-3.3.12.tar.xz
cd procps-ng-3.3.12

./configure --prefix=/usr                            \
            --exec-prefix=                           \
            --libdir=/usr/lib                        \
            --docdir=/usr/share/doc/procps-ng-3.3.12 \
            --disable-static                         \
            --disable-kill
make
sed -i -r 's|(pmap_initname)\\\$|\1|' testsuite/pmap.test/pmap.exp
sed -i '/set tty/d' testsuite/pkill.test/pkill.exp
rm testsuite/pgrep.test/pgrep.exp

make check
make install

mv -v /usr/lib/libprocps.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so

cd ../
rm -R -f procps-ng-3.3.12
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: procps-ng-3.3.12" >>~/slfs_basic_sys.log


tar -xf e2fsprogs-1.43.9.tar.gz
cd e2fsprogs-1.43.9

mkdir -v build
cd build

LIBS=-L/tools/lib                    \
CFLAGS=-I/tools/include              \
PKG_CONFIG_PATH=/tools/lib/pkgconfig \
../configure --prefix=/usr           \
             --bindir=/bin           \
             --with-root-prefix=""   \
             --enable-elf-shlibs     \
             --disable-libblkid      \
             --disable-libuuid       \
             --disable-uuidd         \
             --disable-fsck
make
ln -sfv /tools/lib/lib{blk,uu}id.so.1 lib
make LD_LIBRARY_PATH=/tools/lib check
make install
make install-libs
chmod -v u+w /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
gunzip -v /usr/share/info/libext2fs.info.gz
install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo
install -v -m644 doc/com_err.info /usr/share/info
install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info

cd ../../
rm -R -f e2fsprogs-1.43.9
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: e2fsprogs-1.43.9" >>~/slfs_basic_sys.log


tar -xf coreutils-8.29.tar.xz
cd coreutils-8.29

patch -Np1 -i ../coreutils-8.29-i18n-1.patch
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
FORCE_UNSAFE_CONFIGURE=1 ./configure \
            --prefix=/usr            \
            --enable-no-install-program=kill,uptime
FORCE_UNSAFE_CONFIGURE=1 make
make NON_ROOT_USERNAME=nobody check-root
echo "dummy:x:1000:nobody" >> /etc/group
chown -Rv nobody . 
su nobody -s /bin/bash \
          -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check"
sed -i '/dummy/d' /etc/group
make install

mv -v /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
mv -v /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
mv -v /usr/bin/{rmdir,stty,sync,true,uname} /bin
mv -v /usr/bin/chroot /usr/sbin
mv -v /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
sed -i s/\"1\"/\"8\"/1 /usr/share/man/man8/chroot.8

mv -v /usr/bin/{head,sleep,nice} /bin

cd ../
rm -R -f coreutils-8.29
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: coreutils-8.29" >>~/slfs_basic_sys.log


tar -xf check-0.12.0.tar.gz
cd check-0.12.0

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f check-0.12.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: check-0.12.0" >>~/slfs_basic_sys.log


tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f diffutils-3.6
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: diffutils-3.6" >>~/slfs_basic_sys.log


tar -xf gawk-4.2.0.tar.xz
cd gawk-4.2.0

sed -i 's/extras//' Makefile.in
./configure --prefix=/usr
make
make check
make install

mkdir -v /usr/share/doc/gawk-4.2.0
cp    -v doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-4.2.0

cd ../
rm -R -f gawk-4.2.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: gawk-4.2.0" >>~/slfs_basic_sys.log


tar -xf findutils-4.6.0.tar.gz
cd findutils-4.6.0

sed -i 's/test-lock..EXEEXT.//' tests/Makefile.in
./configure --prefix=/usr --localstatedir=/var/lib/locate
make
make check
make install

mv -v /usr/bin/find /bin
sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb

cd ../
rm -R -f findutils-4.6.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: findutils-4.6.0" >>~/slfs_basic_sys.log


tar -xf groff-1.22.3.tar.gz
cd groff-1.22.3

PAGE=A4 ./configure --prefix=/usr
make -j1
make install

cd ../
rm -R -f groff-1.22.3
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: groff-1.22.3" >>~/slfs_basic_sys.log


tar -xf grub-2.02.tar.xz
cd grub-2.02

./configure --prefix=/usr          \
            --sbindir=/sbin        \
            --sysconfdir=/etc      \
            --disable-efiemu       \
            --disable-werror

make
make install

cd ../
rm -R -f grub-2.02
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: grub-2.02" >>~/slfs_basic_sys.log


tar -xf less-530.tar.gz
cd less-530

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd ../
rm -R -f less-530
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: less-530" >>~/slfs_basic_sys.log


tar -xf gzip-1.9.tar.xz
cd gzip-1.9

./configure --prefix=/usr
make
make check
make install

mv -v /usr/bin/gzip /bin

cd ../
rm -R -f gzip-1.9
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: gzip-1.9" >>~/slfs_basic_sys.log


tar -xf iproute2-4.15.0.tar.xz
cd iproute2-4.15.0

sed -i /ARPD/d Makefile
rm -fv man/man8/arpd.8
sed -i 's/m_ipt.o//' tc/Makefile

make
make DOCDIR=/usr/share/doc/iproute2-4.15.0 install

cd ../
rm -R -f iproute2-4.15.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: iproute2-4.15.0" >>~/slfs_basic_sys.log


tar -xf kbd-2.0.4.tar.xz
cd kbd-2.0.4

patch -Np1 -i ../kbd-2.0.4-backspace-1.patch
sed -i 's/\(RESIZECONS_PROGS=\)yes/\1no/g' configure
sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
PKG_CONFIG_PATH=/tools/lib/pkgconfig ./configure --prefix=/usr --disable-vlock

make
make check
make install

mkdir -v /usr/share/doc/kbd-2.0.4
cp -R -v docs/doc/* /usr/share/doc/kbd-2.0.4

cd ../
rm -R -f kbd-2.0.4
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: kbd-2.0.4" >>~/slfs_basic_sys.log


tar -xf libpipeline-1.5.0.tar.gz
cd libpipeline-1.5.0

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f libpipeline-1.5.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: libpipeline-1.5.0" >>~/slfs_basic_sys.log


tar -xf make-4.2.1.tar.bz2
cd make-4.2.1

sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/usr
make
make PERL5LIB=$PWD/tests/ check
make install

cd ../
rm -R -f make-4.2.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: make-4.2.1" >>~/slfs_basic_sys.log


tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f patch-2.7.6
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: patch-2.7.6" >>~/slfs_basic_sys.log


tar -xf sysklogd-1.5.1.tar.gz
cd sysklogd-1.5.1

sed -i '/Error loading kernel symbols/{n;n;d}' ksym_mod.c
sed -i 's/union wait/int/' syslogd.c
make
make BINDIR=/sbin install

cat > /etc/syslog.conf << "EOF"
# Begin /etc/syslog.conf

auth,authpriv.* -/var/log/auth.log
*.*;auth,authpriv.none -/var/log/sys.log
daemon.* -/var/log/daemon.log
kern.* -/var/log/kern.log
mail.* -/var/log/mail.log
user.* -/var/log/user.log
*.emerg *

# End /etc/syslog.conf
EOF

cd ../
rm -R -f sysklogd-1.5.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: sysklogd-1.5.1" >>~/slfs_basic_sys.log


tar -xf sysvinit-2.88dsf.tar.bz2
cd sysvinit-2.88dsf

patch -Np1 -i ../sysvinit-2.88dsf-consolidated-1.patch
make -C src
make -C src install

cd ../
rm -R -f sysvinit-2.88dsf
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: sysvinit-2.88dsf" >>~/slfs_basic_sys.log


tar -xf eudev-3.2.5.tar.gz
cd eudev-3.2.5

sed -r -i 's|/usr(/bin/test)|\1|' test/udev-test.pl
cat > config.cache << "EOF"
HAVE_BLKID=1
BLKID_LIBS="-lblkid"
BLKID_CFLAGS="-I/tools/include"
EOF

./configure --prefix=/usr           \
            --bindir=/sbin          \
            --sbindir=/sbin         \
            --libdir=/usr/lib       \
            --sysconfdir=/etc       \
            --libexecdir=/lib       \
            --with-rootprefix=      \
            --with-rootlibdir=/lib  \
            --enable-manpages       \
            --disable-static        \
            --config-cache

LIBRARY_PATH=/tools/lib make

mkdir -pv /lib/udev/rules.d
mkdir -pv /etc/udev/rules.d

make LD_LIBRARY_PATH=/tools/lib check

make LD_LIBRARY_PATH=/tools/lib install

tar -xvf ../udev-lfs-20171102.tar.bz2
make -f udev-lfs-20171102/Makefile.lfs install

LD_LIBRARY_PATH=/tools/lib udevadm hwdb --update

cd ../
rm -R -f eudev-3.2.5
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: eudev-3.2.5" >>~/slfs_basic_sys.log


tar -xf util-linux-2.31.1.tar.xz
cd util-linux-2.31.1

mkdir -pv /var/lib/hwclock
./configure ADJTIME_PATH=/var/lib/hwclock/adjtime   \
            --docdir=/usr/share/doc/util-linux-2.31.1 \
            --disable-chfn-chsh  \
            --disable-login      \
            --disable-nologin    \
            --disable-su         \
            --disable-setpriv    \
            --disable-runuser    \
            --disable-pylibmount \
            --disable-static     \
            --without-python     \
            --without-systemd    \
            --without-systemdsystemunitdir
make
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make -k check"
make install

cd ../
rm -R -f util-linux-2.31.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: util-linux-2.31.1" >>~/slfs_basic_sys.log


tar -xf man-db-2.8.1.tar.xz
cd man-db-2.8.1

./configure --prefix=/usr                        \
            --docdir=/usr/share/doc/man-db-2.8.1 \
            --sysconfdir=/etc                    \
            --disable-setuid                     \
            --enable-cache-owner=bin             \
            --with-browser=/usr/bin/lynx         \
            --with-vgrind=/usr/bin/vgrind        \
            --with-grap=/usr/bin/grap            \
            --with-systemdtmpfilesdir=
make
make check
make install

cd ../
rm -R -f man-db-2.8.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: man-db-2.8.1" >>~/slfs_basic_sys.log


tar -xf tar-1.30.tar.xz
cd tar-1.30

FORCE_UNSAFE_CONFIGURE=1  \
./configure --prefix=/usr \
            --bindir=/bin

make
make check
make install
make -C doc install-html docdir=/usr/share/doc/tar-1.30

cd ../
rm -R -f tar-1.30
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: tar-1.30" >>~/slfs_basic_sys.log


tar -xf texinfo-6.5.tar.xz
cd texinfo-6.5

./configure --prefix=/usr --disable-static
make
make check
make install
make TEXMF=/usr/share/texmf install-tex

pushd /usr/share/info
rm -v dir
for f in *
  do install-info $f dir 2>/dev/null
done
popd

cd ../
rm -R -f texinfo-6.5
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: texinfo-6.5" >>~/slfs_basic_sys.log


tar -xf vim-8.0.586.tar.bz2
cd vim80

echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
sed -i '/call/{s/split/xsplit/;s/303/492/}' src/testdir/test_recover.vim
./configure --prefix=/usr
make
make -j1 test &> vim-test.log
make install

ln -sv vim /usr/bin/vi
for L in  /usr/share/man/{,*/}man1/vim.1; do
    ln -sv vim.1 $(dirname $L)/vi.1
done

ln -sv ../vim/vim80/doc /usr/share/doc/vim-8.0.586

cat > /etc/vimrc << "EOF"
" Begin /etc/vimrc

" Ensure defaults are set before customizing settings, not after
source $VIMRUNTIME/defaults.vim
let skip_defaults_vim=1 

set nocompatible
set backspace=2
set mouse=
syntax on
if (&term == "xterm") || (&term == "putty")
  set background=dark
endif

" End /etc/vimrc
EOF


cd ../
rm -R -f vim80
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo -e "`date`\t$difftimelps\t\tProcessed: vim80" >>~/slfs_basic_sys.log


save_lib="ld-2.27.so libc-2.27.so libpthread-2.27.so libthread_db-1.0.so"

cd /lib
for LIB in $save_lib; do
    objcopy --only-keep-debug $LIB $LIB.dbg 
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB 
done 

save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.24
             libmpx.so.2.0.1 libmpxwrappers.so.2.0.1 libitm.so.1.0.0
             libcilkrts.so.5.0.0 libatomic.so.1.2.0"

cd /usr/lib
for LIB in $save_usrlib; do
    objcopy --only-keep-debug $LIB $LIB.dbg
    strip --strip-unneeded $LIB
    objcopy --add-gnu-debuglink=$LIB.dbg $LIB
done

unset LIB save_lib save_usrlib
logout

