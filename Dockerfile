FROM ubuntu:16.04

## set non-interactive frontend for debconf
ENV DEBIAN_FRONTEND noninteractive

## Add ubiquiti repo to apt
COPY ./100-ubnt-unifi.list /etc/apt/sources.list.d/

## install unifi controller and other necessary software
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 06E85760C0A52C50 &&\
    apt-get update &&\
    apt-get install -y unifi unzip

## change unifi controller log4j appenders to stdout (i.e. disable file appenders)
RUN unzip /usr/lib/unifi/lib/ace.jar log4j.properties -d /opt/unifi/ &&\
    sed -i.default 's/^\(^log4j\.appender\.[^.]\+\)=\(.*\)/\1=org.apache.log4j.ConsoleAppender/' /opt/unifi/log4j.properties

## (ToDo) install unifi controller server certificate

## install container init/boot script
COPY ./init.sh /opt/unifi/
RUN chmod u+x /opt/unifi/init.sh

## expose ports
EXPOSE 8080
EXPOSE 8443
EXPOSE 3478

## set default command
CMD /opt/unifi/init.sh

