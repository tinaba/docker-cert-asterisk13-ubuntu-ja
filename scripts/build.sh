#!/bin/sh -x

minimal_apt_get_args='-y --no-install-recommends'

SERVICE_PACKAGES="nano tar htop curl ca-certificates"
LIBS_PACKAGES="libxml2-dev libjansson-dev libncurses5-dev libgsm1-dev libspeex-dev libspeexdsp-dev libssl-dev libsqlite3-dev"
BUILD_PACKAGES="wget git subversion build-essential uuid-dev unixodbc-dev pkg-config"
RUN_PACKAGES="openssl sqlite3 fail2ban iptables"

apt-get update -y
apt-get install $minimal_apt_get_args $SERVICE_PACKAGES $LIBS_PACKAGES $BUILD_PACKAGES

# pjsip
git clone -b pjproject-2.4.5 https://github.com/asterisk/pjproject /tmp/pjproject
cd /tmp/pjproject

./configure --libdir=/usr/lib/x86_64-linux-gnu --prefix=/usr --enable-shared --disable-sound --disable-resample --disable-video --disable-opencore-amr CFLAGS='-O2 -DNDEBUG'
make dep && make && make install && ldconfig && ldconfig -p | grep pj

# asterisk-certified
cd /tmp
git clone -b certified/13.8-cert4 https://github.com/asterisk/asterisk /tmp/asterisk

cd /tmp/asterisk
sh contrib/scripts/get_mp3_source.sh
cp /tmp/menuselect.makeopts /tmp/asterisk/menuselect.makeopts
./configure CFLAGS='-g -O2 -mtune=native' --libdir=/usr/lib/x86_64-linux-gnu
make && make install && make samples

touch /var/log/auth.log /var/log/asterisk/messages /var/log/asterisk/security

# install run packages
apt-get install $minimal_apt_get_args $RUN_PACKAGES

# fail2ban configure
rm /etc/fail2ban/filter.d/asterisk.conf
cp /tmp/asterisk*.conf /etc/fail2ban/filter.d/
cat /tmp/jail.conf >> /etc/fail2ban/jail.conf

# clean
apt-get remove --purge -y $BUILD_PACKAGES
apt-get -y autoremove
apt-get -y clean
rm -rf /tmp/* /var/tmp/*
rm -rf /var/lib/apt/lists/*
