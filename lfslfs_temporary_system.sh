
begin=$(date +"%s")
echo "STARTING SLFS"

tar -xf binutils-2.30.tar.xz
cd binutils-2.30
mkdir -v build
cd build

../configure --prefix=/tools            \
             --with-sysroot=$LFS        \
             --with-lib-path=/tools/lib \
             --target=$LFS_TGT          \
             --disable-nls              \
             --disable-werror

make

case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac

make install

cd ../../
rm -R -f binutils-2.30

tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0
tar -xf ../mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
 ;;
esac

mkdir -v build
cd build

../configure                                       \
    --target=$LFS_TGT                              \
    --prefix=/tools                                \
    --with-glibc-version=2.11                      \
    --with-sysroot=$LFS                            \
    --with-newlib                                  \
    --without-headers                              \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --disable-nls                                  \
    --disable-shared                               \
    --disable-multilib                             \
    --disable-decimal-float                        \
    --disable-threads                              \
    --disable-libatomic                            \
    --disable-libgomp                              \
    --disable-libmpx                               \
    --disable-libquadmath                          \
    --disable-libssp                               \
    --disable-libvtv                               \
    --disable-libstdcxx                            \
    --enable-languages=c,c++


make

make install

cd ../../
rm -R -f gcc-7.3.0


tar -xf linux-4.15.3.tar.xz
cd linux-4.15.3
make mrproper
make INSTALL_HDR_PATH=dest headers_install
cp -rv dest/include/* /tools/include
cd ../
rm -R -f linux-4.15.3


tar -xf glibc-2.27.tar.xz
cd glibc-2.27
patch -p1 < ../glibc-2.27-fhs-1.patch

mkdir -v build
cd build

../configure                             \
      --prefix=/tools                    \
      --host=$LFS_TGT                    \
      --build=$(../scripts/config.guess) \
      --enable-kernel=3.2                \
      --with-headers=/tools/include      \
      libc_cv_forced_unwind=yes          \
      libc_cv_c_cleanup=yes

make
make install

echo 'int main(){}' > dummy.c
$LFS_TGT-gcc dummy.c
readelf -l a.out | grep ': /tools'
rm -v dummy.c a.out

cd ../../
rm -R -f glibc-2.27

tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

mkdir -v build
cd build

../libstdc++-v3/configure           \
    --host=$LFS_TGT                 \
    --prefix=/tools                 \
    --disable-multilib              \
    --disable-nls                   \
    --disable-libstdcxx-threads     \
    --disable-libstdcxx-pch         \
    --with-gxx-include-dir=/tools/$LFS_TGT/include/c++/7.3.0

make
make install

cd ../../
rm -R -f gcc-7.3.0

tar -xf binutils-2.30.tar.xz
cd binutils-2.30 
mkdir -v build
cd build

CC=$LFS_TGT-gcc                \
AR=$LFS_TGT-ar                 \
RANLIB=$LFS_TGT-ranlib         \
../configure                   \
    --prefix=/tools            \
    --disable-nls              \
    --disable-werror           \
    --with-lib-path=/tools/lib \
    --with-sysroot

make
make install

make -C ld clean
make -C ld LIB_PATH=/usr/lib:/lib
cp -v ld/ld-new /tools/bin

cd ../../
 rm -R -f binutils-2.30

tar -xf gcc-7.3.0.tar.xz
cd gcc-7.3.0

cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
  `dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/include-fixed/limits.h

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
      -e 's@/usr@/tools@g' $file.orig > $file
  echo '
#undef STANDARD_STARTFILE_PREFIX_1
#undef STANDARD_STARTFILE_PREFIX_2
#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
#define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
        -i.orig gcc/config/i386/t-linux64
  ;;
esac

tar -xf ../mpfr-4.0.1.tar.xz
mv -v mpfr-4.0.1 mpfr
tar -xf ../gmp-6.1.2.tar.xz
mv -v gmp-6.1.2 gmp
tar -xf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

mkdir -v build
cd build

CC=$LFS_TGT-gcc                                    \
CXX=$LFS_TGT-g++                                   \
AR=$LFS_TGT-ar                                     \
RANLIB=$LFS_TGT-ranlib                             \
../configure                                       \
    --prefix=/tools                                \
    --with-local-prefix=/tools                     \
    --with-native-system-header-dir=/tools/include \
    --enable-languages=c,c++                       \
    --disable-libstdcxx-pch                        \
    --disable-multilib                             \
    --disable-bootstrap                            \
    --disable-libgomp

make
make install

ln -sv gcc /tools/bin/cc

cd ../../
rm -R -f gcc-7.3.0

tar -xf tcl8.6.8-src.tar.gz
cd tcl8.6.8

cd unix
./configure --prefix=/tools
make
TZ=UTC make test
make install

chmod -v u+w /tools/lib/libtcl8.6.so
make install-private-headers
ln -sv tclsh8.6 /tools/bin/tclsh

cd ../../
rm -R -f tcl8.6.8

tar -xf expect5.45.4.tar.gz
cd expect5.45.4

cp -v configure{,.orig}
sed 's:/usr/local/bin:/bin:' configure.orig > configure

./configure --prefix=/tools       \
            --with-tcl=/tools/lib \
            --with-tclinclude=/tools/include

make
make test
make SCRIPTS="" install

cd ../
rm -R -f expect5.45.4

tar -xf dejagnu-1.6.1.tar.gz
cd dejagnu-1.6.1

./configure --prefix=/tools
make install
make check

cd ../
rm -R -f dejagnu-1.6.1

tar -xf m4-1.4.18.tar.xz
cd m4-1.4.18

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f m4-1.4.18

tar -xf ncurses-6.1.tar.gz
cd ncurses-6.1
sed -i s/mawk// configure

./configure --prefix=/tools \
            --with-shared   \
            --without-debug \
            --without-ada   \
            --enable-widec  \
            --enable-overwrite
make
make install

cd ../
rm -R -f ncurses-6.1

tar -xf bash-4.4.18.tar.gz
cd bash-4.4.18

./configure --prefix=/tools --without-bash-malloc
make
make tests
make install
ln -sv bash /tools/bin/sh

cd ../
rm -R -f bash-4.4.18

tar -xf bison-3.0.4.tar.xz
cd bison-3.0.4

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f bison-3.0.4

tar -xf bzip2-1.0.6.tar.gz
cd bzip2-1.0.6
patch -p1 < ../bzip2-1.0.6-install_docs-1.patch
make
make PREFIX=/tools install
cd ../
rm -R -f bzip2-1.0.6

tar -xf coreutils-8.29.tar.xz
cd coreutils-8.29
patch -p1 < ../coreutils-8.29-i18n-1.patch

./configure --prefix=/tools --enable-install-program=hostname
make
make RUN_EXPENSIVE_TESTS=yes check
make install

cd ../
rm -R -f coreutils-8.29

tar -xf diffutils-3.6.tar.xz
cd diffutils-3.6

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f diffutils-3.6

tar -xf file-5.32.tar.gz
cd file-5.32

./configure --prefix=/tools
make 
make check
make install

cd ../
rm -R -f file-5.32

tar -xf findutils-4.6.0.tar.gz
cd findutils-4.6.0

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f findutils-4.6.0

tar -xf gawk-4.2.0.tar.xz
cd gawk-4.2.0

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f gawk-4.2.0

tar -xf gettext-0.19.8.1.tar.xz
cd gettext-0.19.8.1
cd gettext-tools

EMACS="no" ./configure --prefix=/tools --disable-shared
make -C gnulib-lib
make -C intl pluralx.c
make -C src msgfmt
make -C src msgmerge
make -C src xgettext
cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin

cd ../../
rm -R -f gettext-tools/

tar -xf grep-3.1.tar.xz
cd grep-3.1

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f grep-3.1

tar -xf gzip-1.9.tar.xz
cd gzip-1.9

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f gzip-1.9

tar -xf make-4.2.1.tar.bz2
cd make-4.2.1

sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
./configure --prefix=/tools --without-guile
make
# make check
make install

cd ../
rm -R -f make-4.2.1

tar -xf patch-2.7.6.tar.xz
cd patch-2.7.6

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f patch-2.7.6

tar -xf perl-5.26.1.tar.xz
cd perl-5.26.1
sh Configure -des -Dprefix=/tools -Dlibs=-lm
make
cp -v perl cpan/podlators/scripts/pod2man /tools/bin
mkdir -pv /tools/lib/perl5/5.26.1
cp -Rv lib/* /tools/lib/perl5/5.26.1

cd ../
rm -R -f perl-5.26.1

tar -xf sed-4.4.tar.xz
cd sed-4.4

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f sed-4.4

tar -xf tar-1.30.tar.xz
cd tar-1.30

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f tar-1.30

tar -xf texinfo-6.5.tar.xz
cd texinfo-6.5

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f texinfo-6.5

tar -xf util-linux-2.31.1.tar.xz
cd util-linux-2.31.1

./configure --prefix=/tools                \
            --without-python               \
            --disable-makeinstall-chown    \
            --without-systemdsystemunitdir \
            --without-ncurses              \
            PKG_CONFIG=""

make
make install

cd ../
rm -R -f util-linux-2.31.1

tar -xf xz-5.2.3.tar.xz
cd xz-5.2.3

./configure --prefix=/tools
make
make check
make install

cd ../
rm -R -f xz-5.2.3

strip --strip-debug /tools/lib/*
/usr/bin/strip --strip-unneeded /tools/{,s}bin/*
rm -rf /tools/{,share}/{info,man,doc}
find /tools/{lib,libexec} -name \*.la -delete

echo "WHO IS THE MAN"
termin=$(date +"%s")
difftimelps=$(($termin-$begin))
echo "Execution completed in: $difftimelps seconds"


