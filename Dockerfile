# Certified Asterisk 13 Certified with sip and pjsip channels
FROM ubuntu:latest
MAINTAINER cd "tinaba@ina365.com"

COPY ./scripts/build.sh /tmp/
COPY ./conf/asterisk-build/menuselect.makeopts /tmp/
COPY ./conf/fail2ban/filter.d/asterisk*.conf /tmp/
COPY ./conf/fail2ban/jail.conf /tmp/
COPY ./scripts/start.sh /

RUN /bin/sh /tmp/build.sh

WORKDIR /root
CMD ["/bin/sh", "/start.sh"]
