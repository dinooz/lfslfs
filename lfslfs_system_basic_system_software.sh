

# http://linuxfromscratch.org/lfs/view/stable/chapter06/createfiles.html


begin=$(date +"%s")
echo "STARTING SLFS - Basic System Software"
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Starting SLFS Basic System Software"          > ~/slfs_basic_sys.log

touch /var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v utmp /var/log/lastlog
chmod -v 664  /var/log/lastlog
chmod -v 600  /var/log/btmp

cd /sources

tar -xf linux-4.15.3.tar.xz
cd linux-4.15.3

make mrproper

make INSTALL_HDR_PATH=dest headers_install
find dest/include \( -name .install -o -name ..install.cmd \) -delete
cp -rv dest/include/* /usr/include

cd ../
rm -R -f linux-4.15.3
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: linux-4.15.3"          >>~/slfs_temp_sys.log

tar -xf man-pages-4.15.tar.xz
cd man-pages-4.15

make install

cd ../
rm -R -f man-pages-4.15
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: man-pages-4.15"          >>~/slfs_temp_sys.log

tar -xf glibc-2.27.tar.xz
cd glibc-2.27
patch -Np1 -i ../glibc-2.27-fhs-1.patch
ln -sfv /tools/lib/gcc /usr/lib

case $(uname -m) in
    i?86)    GCC_INCDIR=/usr/lib/gcc/$(uname -m)-pc-linux-gnu/7.3.0/include
            ln -sfv ld-linux.so.2 /lib/ld-lsb.so.3
    ;;
    x86_64) GCC_INCDIR=/usr/lib/gcc/x86_64-pc-linux-gnu/7.3.0/include
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64
            ln -sfv ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
    ;;
esac

rm -f /usr/include/limits.h

mkdir -v build
cd build

CC="gcc -isystem $GCC_INCDIR -isystem /usr/include" \
../configure --prefix=/usr                          \
             --disable-werror                       \
             --enable-kernel=3.2                    \
             --enable-stack-protector=strong        \
             libc_cv_slibdir=/lib
unset GCC_INCDIR

make
make check
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install
cp -v ../nscd/nscd.conf /etc/nscd.conf
mkdir -pv /var/cache/nscd

mkdir -pv /usr/lib/locale
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030

make localedata/install-locales

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf

passwd: files
group: files
shadow: files

hosts: files dns
networks: files

protocols: files
services: files
ethers: files
rpc: files

# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2018c.tar.gz

ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}

for tz in etcetera southamerica northamerica europe africa antarctica  \
          asia australasia backward pacificnew systemv; do
    zic -L /dev/null   -d $ZONEINFO       -y "sh yearistype.sh" ${tz}
    zic -L /dev/null   -d $ZONEINFO/posix -y "sh yearistype.sh" ${tz}
    zic -L leapseconds -d $ZONEINFO/right -y "sh yearistype.sh" ${tz}
done

cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p America/Chicago
unset ZONEINFO

tzselect
cp -v /usr/share/zoneinfo/America/Chicago /etc/localtime

cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib

EOF

cat >> /etc/ld.so.conf << "EOF"
# Add an include directory
include /etc/ld.so.conf.d/*.conf

EOF
mkdir -pv /etc/ld.so.conf.d


cd ../../
rm -R -f glibc-2.27
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: glibc-2.27"          >>~/slfs_temp_sys.log

mv -v /tools/bin/{ld,ld-old}
mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old}
mv -v /tools/bin/{ld-new,ld}
ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld

gcc -dumpspecs | sed -e 's@/tools@@g'                   \
    -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' \
    -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' >      \
    `dirname $(gcc --print-libgcc-file-name)`/specs


echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B1 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

tar -xf zlib-1.2.11.tar.xz
cd zlib-1.2.11

./configure --prefix=/usr
make
make check
make install

mv -v /usr/lib/libz.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so

cd ../
rm -R -f zlib-1.2.11
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: zlib-1.2.11"          >>~/slfs_temp_sys.log

tar -xf file-5.32.tar.gz
cd file-5.32

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f file-5.32
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: file-5.32"          >>~/slfs_temp_sys.log

tar -xf readline-7.0.tar.gz
cd readline-7.0

sed -i '/MV.*old/d' Makefile.in
sed -i '/{OLDSUFF}/c:' support/shlib-install

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/readline-7.0

make SHLIB_LIBS="-L/tools/lib -lncursesw"

make SHLIB_LIBS="-L/tools/lib -lncurses" install

mv -v /usr/lib/lib{readline,history}.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
ln -sfv ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so

install -v -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-7.0

cd ../
rm -R -f readline-7.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: readline-7.0"          >>~/slfs_temp_sys.log


tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18

./configure --prefix=/usr
make
make check
make install

cd ../
rm -R -f cd m4-1.4.18
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: m4-1.4.18"          >>~/slfs_temp_sys.log

tar -xf bc-1.07.1.tar.gz
cd bc-1.07.1

cat > bc/fix-libmath_h << "EOF"
#! /bin/bash
sed -e '1   s/^/{"/' \
    -e     's/$/",/' \
    -e '2,$ s/^/"/'  \
    -e   '$ d'       \
    -i libmath.h

sed -e '$ s/$/0}/' \
    -i libmath.h
EOF

ln -sv /tools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
ln -sfv libncurses.so.6 /usr/lib/libncurses.so

sed -i -e '/flex/s/as_fn_error/: ;; # &/' configure

./configure --prefix=/usr           \
            --with-readline         \
            --mandir=/usr/share/man \
            --infodir=/usr/share/info

make
echo "quit" | ./bc/bc -l Test/checklib.b
make install

cd ../
rm -R -f bc-1.07.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: bc-1.07.1"          >>~/slfs_temp_sys.log


tar -xf binutils-2.30.tar.xz
cd binutils-2.30

expect -c "spawn ls"
mkdir -v build
cd build

../configure --prefix=/usr       \
             --enable-gold       \
             --enable-ld=default \
             --enable-plugins    \
             --enable-shared     \
             --disable-werror    \
             --enable-64-bit-bfd \
             --with-system-zlib 

make tooldir=/usr

make -k check
make tooldir=/usr install

cd ../../
rm -R -f binutils-2.30
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: binutils-2.30"          >>~/slfs_temp_sys.log


tar -xf gmp-6.1.2.tar.xz
cd gmp-6.1.2

ABI=32 ./configure ...
cp -v configfsf.guess config.guess
cp -v configfsf.sub   config.sub

./configure --prefix=/usr    \
            --enable-cxx     \
            --disable-static \
            --docdir=/usr/share/doc/gmp-6.1.2

make
make html
make check 2>&1 | tee gmp-check-log
awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log

make install
make install-html

cd ../
rm -R -f gmp-6.1.2
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: gmp-6.1.2"          >>~/slfs_temp_sys.log


tar -xf mpfr-4.0.1.tar.xz
cd mpfr-4.0.1

./configure --prefix=/usr        \
            --disable-static     \
            --enable-thread-safe \
            --docdir=/usr/share/doc/mpfr-4.0.1

make
make html
make check
make install
make install-html

cd ../
rm -R -f mpfr-4.0.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: mpfr-4.0.1"          >>~/slfs_temp_sys.log

tar -xf mpc-1.1.0.tar.gz
cd mpc-1.1.0

./configure --prefix=/usr    \
            --disable-static \
            --docdir=/usr/share/doc/mpc-1.1.0

make
make html
make check
make install
make install-html

cd ../
rm -R -f mpc-1.1.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: mpc-1.1.0"          >>~/slfs_temp_sys.log

tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac


rm -f /usr/lib/gcc

mkdir -v build
cd build

SED=sed                               \
../configure --prefix=/usr            \
             --enable-languages=c,c++ \
             --disable-multilib       \
             --disable-bootstrap      \
             --with-system-zlib

make
ulimit -s 32768
make -k check
../contrib/test_summary
make install
ln -sv ../usr/bin/cpp /lib
ln -sv gcc /usr/bin/cc
install -v -dm755 /usr/lib/bfd-plugins
ln -sfv ../../libexec/gcc/$(gcc -dumpmachine)/7.3.0/liblto_plugin.so \
        /usr/lib/bfd-plugins/

echo 'int main(){}' > dummy.c
cc dummy.c -v -Wl,--verbose &> dummy.log
readelf -l a.out | grep ': /lib'

grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log

grep -B4 '^ /usr/include' dummy.log

grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'

grep "/lib.*/libc.so.6 " dummy.log

grep found dummy.log

rm -v dummy.c a.out dummy.log

mkdir -pv /usr/share/gdb/auto-load/usr/lib
mv -v /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib

cd ../../
rm -R -f gcc-7.3.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: gcc-7.3.0"          >>~/slfs_temp_sys.log


tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6

patch -Np1 -i ../bzip2-1.0.6-install_docs-1.patch
sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
make -f Makefile-libbz2_so
make clean
make
make PREFIX=/usr install

cp -v bzip2-shared /bin/bzip2
cp -av libbz2.so* /lib
ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
rm -v /usr/bin/{bunzip2,bzcat,bzip2}
ln -sv bzip2 /bin/bunzip2
ln -sv bzip2 /bin/bzcat

cd ../
rm -R -f bzip2-1.0.6
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: bzip2-1.0.6"          >>~/slfs_temp_sys.log


tar -xf pkg-config-0.29.2.tar.gz
cd pkg-config-0.29.2

./configure --prefix=/usr              \
            --with-internal-glib       \
            --disable-host-tool        \
            --docdir=/usr/share/doc/pkg-config-0.29.2

make
make check
make install

cd ../
rm -R -f pkg-config-0.29.2
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: pkg-config-0.29.2"          >>~/slfs_temp_sys.log


tar -xf ncurses-6.1.tar.gz
cd ncurses-6.1

sed -i '/LIBTOOL_INSTALL/d' c++/Makefile.in
./configure --prefix=/usr           \
            --mandir=/usr/share/man \
            --with-shared           \
            --without-debug         \
            --without-normal        \
            --enable-pc-files       \
            --enable-widec

make
make install

mv -v /usr/lib/libncursesw.so.6* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so

for lib in ncurses form panel menu ; do
    rm -vf                    /usr/lib/lib${lib}.so
    echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
    ln -sfv ${lib}w.pc        /usr/lib/pkgconfig/${lib}.pc
done

rm -vf /usr/lib/libcursesw.so
echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
ln -sfv libncurses.so /usr/lib/libcurses.so

mkdir -v /usr/share/doc/ncurses-6.1
cp -v -R doc/* /usr/share/doc/ncurses-6.1

cd ../
rm -R -f ncurses-6.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: ncurses-6.1"          >>~/slfs_temp_sys.log


tar -xf attr-2.4.47.src.tar.gz
cd attr-2.4.47

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i -e "/SUBDIRS/s|man[25]||g" man/Makefile
sed -i 's:{(:\\{(:' test/run

./configure --prefix=/usr \
            --bindir=/bin \
            --disable-static

make
make -j1 tests root-tests
make install install-dev install-lib
chmod -v 755 /usr/lib/libattr.so
mv -v /usr/lib/libattr.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so

cd ../
rm -R -f attr-2.4.47
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: attr-2.4.47"          >>~/slfs_temp_sys.log

tar -xf acl-2.2.52.src.tar.gz
cd acl-2.2.52

sed -i -e 's|/@pkg_name@|&-@pkg_version@|' include/builddefs.in
sed -i "s:| sed.*::g" test/{sbits-restore,cp,misc}.test
sed -i 's/{(/\\{(/' test/run
sed -i -e "/TABS-1;/a if (x > (TABS-1)) x = (TABS-1);" \
    libacl/__acl_to_any_text.c

./configure --prefix=/usr    \
            --bindir=/bin    \
            --disable-static \
            --libexecdir=/usr/lib

make
make install install-dev install-lib
chmod -v 755 /usr/lib/libacl.so
mv -v /usr/lib/libacl.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so

cd ../
rm -R -f acl-2.2.52
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: acl-2.2.52"          >>~/slfs_temp_sys.log

tar -xf libcap-2.25.tar.xz
cd libcap-2.25

sed -i '/install.*STALIBNAME/d' libcap/Makefile
make
make RAISE_SETFCAP=no lib=lib prefix=/usr install
chmod -v 755 /usr/lib/libcap.so
mv -v /usr/lib/libcap.so.* /lib
ln -sfv ../../lib/$(readlink /usr/lib/libcap.so) /usr/lib/libcap.so

cd ../
rm -R -f libcap-2.25
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: libcap-2.25"          >>~/slfs_temp_sys.log

tar -xf sed-4.4.tar.xz
cd sed-4.4

sed -i 's/usr/tools/' build-aux/help2man
sed -i 's/testsuite.panic-tests.sh//' Makefile.in

./configure --prefix=/usr --bindir=/bin
make
make html
make check
make install

install -d -m755 /usr/share/doc/sed-4.4
install -m644 doc/sed.html /usr/share/doc/sed-4.4

cd ../
rm -R -f sed-4.4
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: sed-4.4"          >>~/slfs_temp_sys.log


tar -xf shadow-4.5.tar.xz
cd shadow-4.5

sed -i 's/groups$(EXEEXT) //' src/Makefile.in
find man -name Makefile.in -exec sed -i 's/groups\.1 / /'   {} \;
find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
find man -name Makefile.in -exec sed -i 's/passwd\.5 / /'   {} \;

sed -i -e 's@#ENCRYPT_METHOD DES@ENCRYPT_METHOD SHA512@' \
       -e 's@/var/spool/mail@/var/mail@' etc/login.defs

sed -i 's@DICTPATH.*@DICTPATH\t/lib/cracklib/pw_dict@' etc/login.defs
sed -i 's/1000/999/' etc/useradd

./configure --sysconfdir=/etc --with-group-name-max-length=32

make
make install
mv -v /usr/bin/passwd /bin

pwconv
grpconv

sed -i 's/yes/no/' /etc/default/useradd

passwd root

cd ../
rm -R -f shadow-4.5
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: shadow-4.5"          >>~/slfs_temp_sys.log

tar -xf psmisc-23.1.tar.xz
cd psmisc-23.1

./configure --prefix=/usr
make
make install

mv -v /usr/bin/fuser /bin
mv -v /usr/bin/killall /bin

cd ../
rm -R -f psmisc-23.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: psmisc-23.1"          >>~/slfs_temp_sys.log

tar -xf iana-etc-2.30.tar.bz2
cd iana-etc-2.30

make
make install

cd ../
rm -R -f iana-etc-2.30
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: iana-etc-2.30"          >>~/slfs_temp_sys.log

tar -xf bison-3.0.4.tar.xz
cd bison-3.0.4

./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.0.4
make
make install

cd ../
rm -R -f bison-3.0.4
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: bison-3.0.4"          >>~/slfs_temp_sys.log

tar -xf flex-2.6.4.tar.gz
cd flex-2.6.4

sed -i "/math.h/a #include <malloc.h>" src/flexdef.h
HELP2MAN=/tools/bin/true \
./configure --prefix=/usr --docdir=/usr/share/doc/flex-2.6.4
make
make check
make install
ln -sv flex /usr/bin/lex

cd ../
rm -R -f flex-2.6.4
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: flex-2.6.4"          >>~/slfs_temp_sys.log

tar -xf grep-3.1.tar.xz
cd grep-3.1

./configure --prefix=/usr --bindir=/bin
make
make check
make install

cd ../
rm -R -f grep-3.1
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: grep-3.1"          >>~/slfs_temp_sys.log

tar -xf bash-4.4.18.tar.gz
cd bash-4.4.18

./configure --prefix=/usr                       \
            --docdir=/usr/share/doc/bash-4.4.18 \
            --without-bash-malloc               \
            --with-installed-readline

make
chown -Rv nobody .
su nobody -s /bin/bash -c "PATH=$PATH make tests"
make install
mv -vf /usr/bin/bash /bin
exec /bin/bash --login +h

cd ../
rm -R -f bash-4.4.18
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: bash-4.4.18"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: libtool-2.4.6"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: gdbm-1.14.1"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: gperf-3.1"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: expat-2.2.5"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: inetutils-1.9.4"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: perl-5.26.1"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: XML-Parser-2.44"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: intltool-0.51.0"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: autoconf-2.69"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: automake-1.15.1"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: xz-5.2.3"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: kmod-25"          >>~/slfs_temp_sys.log

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
echo "`date`    $difftimelps                    Processed: gettext-0.19.8.1"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: elfutils-0.170"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: libffi-3.2.1"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: openssl-1.1.0g"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: Python-3.6.4"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: ninja-1.8.2"          >>~/slfs_temp_sys.log


tar -xf meson-0.44.0.tar.gz
cd meson-0.44.0

python3 setup.py build
python3 setup.py install

cd ../
rm -R -f meson-0.44.0
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: meson-0.44.0"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: procps-ng-3.3.12"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: e2fsprogs-1.43.9"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: coreutils-8.29"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: check-0.12.0"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: diffutils-3.6"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: gawk-4.2.0"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: findutils-4.6.0"          >>~/slfs_temp_sys.log


tar -xf groff-1.22.3.tar.gz
cd groff-1.22.3

PAGE=A4 ./configure --prefix=/usr
make -j1
make install

cd ../
rm -R -f groff-1.22.3
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: groff-1.22.3"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: grub-2.02"          >>~/slfs_temp_sys.log


tar -xf less-530.tar.gz
cd less-530

./configure --prefix=/usr --sysconfdir=/etc
make
make install

cd ../
rm -R -f less-530
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: less-530"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: gzip-1.9"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: iproute2-4.15.0"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: kbd-2.0.4"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: libpipeline-1.5.0"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: make-4.2.1"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: patch-2.7.6"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: sysklogd-1.5.1"          >>~/slfs_temp_sys.log


tar -xf sysvinit-2.88dsf.tar.bz2
cd sysvinit-2.88dsf

patch -Np1 -i ../sysvinit-2.88dsf-consolidated-1.patch
make -C src
make -C src install

cd ../
rm -R -f sysvinit-2.88dsf
nowis=$(date +"%s")
difftimelps=$(($nowis-$begin))
echo "`date`    $difftimelps                    Processed: sysvinit-2.88dsf"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: eudev-3.2.5"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: util-linux-2.31.1"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: man-db-2.8.1"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: tar-1.30"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: texinfo-6.5"          >>~/slfs_temp_sys.log


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
echo "`date`    $difftimelps                    Processed: vim80"          >>~/slfs_temp_sys.log


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

