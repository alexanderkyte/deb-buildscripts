#!/bin/bash
export NAME=openocd
export VERSION=0.9.0
export DEBVERSION=${VERSION}-2
export URL="http://downloads.sourceforge.net/project/openocd/openocd/${VERSION}/openocd-${VERSION}.tar.bz2?r=http%3A%2F%2Fsourceforge.net%2Fprojects%2Fopenocd%2Ffiles%2Fopenocd%2F${VERSION}%2F&ts=1368821905&use_mirror=switch"
#Download it
if [ ! -f "${NAME}_${VERSION}.orig.tar.bz2" ]
then
    wget "$URL" -O ${NAME}_${VERSION}.orig.tar.bz2
fi
tar xjvf ${NAME}_${VERSION}.orig.tar.bz2
cd openocd-${VERSION}
rm -rf debian
mkdir -p debian
#Use the existing COPYING file
touch debian/copyright
#Create the changelog (no messages - dummy)
dch --create -v $DEBVERSION --package ${NAME} ""
#Create copyright file
cp COPYING debian/copyright
#Create control file
echo "Source: $NAME" > debian/control
echo "Maintainer: None <none@example.com>" >> debian/control
echo "Section: misc" >> debian/control
echo "Priority: optional" >> debian/control
echo "Standards-Version: 3.9.2" >> debian/control
echo "Build-Depends: debhelper (>= 8), libftdi-dev, libusb-1.0-0-dev" >> debian/control
#Main library package
echo "" >> debian/control
echo "Package: $NAME" >> debian/control
echo "Architecture: any" >> debian/control
echo "Depends: libhidapi-hidraw0, libusb-1.0-0, libudev1, libnih-dbus1" >> debian/control
echo "Homepage: http://openocd.sourceforge.net" >> debian/control
echo "Description: OpenOCD Debugger (vanilla, btronik)" >> debian/control
#Create rules file
echo '#!/usr/bin/make -f' > debian/rules
echo '%:' >> debian/rules
echo -e '\tdh $@' >> debian/rules
echo 'override_dh_auto_configure:' >> debian/rules
echo -e "\t./configure --prefix=`pwd`/debian/${NAME}/usr" >> debian/rules
echo 'override_dh_auto_build:' >> debian/rules
echo -e '\tmake -j8' >> debian/rules
echo 'override_dh_auto_install:' >> debian/rules
echo -e '\tmake install' >> debian/rules
echo -e "\tmkdir -p debian/$NAME/usr/lib/openocd/scripts" >> debian/rules
echo -e "\tcp -r tcl/* debian/$NAME/usr/lib/openocd/scripts" >> debian/rules
echo 'override_dh_shlibdeps:' >> debian/rules
echo -e '\tdh_shlibdeps --dpkg-shlibdeps-params=--ignore-missing-info' >> debian/rules
#Create some misc files
mkdir -p debian/source
echo "8" > debian/compat
echo "3.0 (quilt)" > debian/source/format
#Build it
debuild -us -uc
