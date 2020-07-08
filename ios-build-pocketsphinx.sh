#!/bin/sh

SCRATCH="scratch"
DEST=`pwd`/"bin"
SPHINXBASE_DIR=`pwd`/../sphinxbase-5prealpha/bin

ARCHS="i386 arm64 armv7 armv7s x86_64"

DEPLOYMENT_TARGET="8.0"

if [ "$*" ]
then
	ARCHS="$*"
fi

CWD=`pwd`

for ARCH in $ARCHS
do
	echo "building $ARCH..."
	mkdir -p "$SCRATCH/$ARCH"
	cd "$SCRATCH/$ARCH"

	if [ "$ARCH" = "i386" -o "$ARCH" = "x86_64" ]
	then
	    PLATFORM="iPhoneSimulator"
	    IOS_CFLAGS="-arch $ARCH -mios-simulator-version-min=$DEPLOYMENT_TARGET"
	    HOST="${ARCH}-apple-darwin"
	else
	    PLATFORM="iPhoneOS"
	    IOS_CFLAGS="-arch $ARCH -mios-version-min=$DEPLOYMENT_TARGET"
	    HOST="arm-apple-darwing"
	fi	
	export DEVELOPER=`xcode-select --print-path`
	export DEVROOT="${DEVELOPER}/Platforms/${PLATFORM}.platform/Developer"
	export SDKROOT="${DEVROOT}/SDKs/${PLATFORM}${IPHONE_SDK}.sdk"
	export CC=`xcrun -find clang`
	export LD=`xcrun -find ld`
	export CFLAGS="-O3 ${IOS_CFLAGS} -isysroot ${SDKROOT} -I$SPHINXBASE_DIR/$ARCH/include/sphinxbase -emit-module"
	export LDFLAGS="${IOS_CFLAGS} -isysroot ${SDKROOT} -L$SPHINXBASE_DIR/$ARCH/lib"
	export CPPFLAGS="${CFLAGS}"

	$CWD/configure \
	    --host="${HOST}" \
	    --prefix="$DEST/$ARCH" \
	    --without-swig-python \
	    --with-sphinxbase="$SPHINXBASE_DIR/$ARCH" \
	|| exit 1

	make -j3 install DESTDIR= || exit 1
	cd $CWD
done

echo Done
