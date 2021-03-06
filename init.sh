#!/bin/bash
#
# /opt/unifi/init.sh -- startup script for Ubiquiti UniFi
#
#
BASEDIR="/usr/lib/unifi"
MAINCLASS="com.ubnt.ace.Launcher"

CODEPATH=${BASEDIR}
DATADIR=${BASEDIR}/data
LOGDIR=${BASEDIR}/logs
RUNDIR=${BASEDIR}/run

## JVM options
JVM_OPTS=""
JVM_OPTS="${JVM_OPTS} -Xmx1024M"
JVM_OPTS="${JVM_OPTS} -Djava.awt.headless=true"

## UNIFI Controller options
UNIFI_OPTS=""
UNIFI_OPTS="${UNIFI_OPTS} -Dlog4j.configuration=file:/opt/unifi/log4j.properties"
UNIFI_OPTS="${UNIFI_OPTS} -Dfile.encoding=UTF-8"
UNIFI_OPTS="${UNIFI_OPTS} -Dunifi.datadir=${DATADIR}"
UNIFI_OPTS="${UNIFI_OPTS} -Dunifi.logdir=${LOGDIR}"
UNIFI_OPTS="${UNIFI_OPTS} -Dunifi.rundir=${RUNDIR}"

## gracefully stops the application
function stop() {
    signal=$1
    echo ""
    echo "!!!! Caught $signal !!!!"
    echo "Stopping application...."
    java -cp ${BASEDIR}/lib/ace.jar ${JVM_OPTS} ${UNIFI_OPTS} ${MAINCLASS} stop

    echo "Application stopped (function)."
}

function start() {
    java -cp ${BASEDIR}/lib/ace.jar ${JVM_OPTS} ${UNIFI_OPTS} ${MAINCLASS} start &
    sleep 2
    tail -f /usr/lib/unifi/logs/server.log
}

# signals to trap for graceful shutdown
trap "stop SIGTERM" INT TERM

cd ${BASEDIR}
start
echo "Application started!"
wait
echo "Application stopped (main)."
