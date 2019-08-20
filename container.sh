#!/bin/bash
## container.sh - Convenience script for containerized application
## development/operations
##
## Actions:
##  build - bhild the container
##  run   - start/run the container attached
##  start - start the container detatched
##  stop  - stop the container
##  kill  - kill the container
##  exec  - exec into the running container (bash)
##
IMAGE_NAME="unifi_controller"
VOLUME_NAME="unifi_controller_data"
VOLUME_MOUNT="/usr/lib/unifi/data"

function build {
    docker build -t $IMAGE_NAME:latest .
}

function createVolume {
    docker volume list -q | grep $VOLUME_NAME > /dev/null
    if [ $? -ne 0 ]; then
        docker volume create $VOLUME_NAME
    fi
}

function run {
    createVolume
    
    docker run -it -p 8080:8080 -p 8443:8443 -v $VOLUME_NAME:$VOLUME_MOUNT $IMAGE_NAME:latest
}

function start {
    createVolume

    docker run -d -p 8080:8080 -p 8443:8443 -v $VOLUME_NAME:$VOLUME_MOUNT $IMAGE_NAME:latest > /dev/null
    docker ps -f "ancestor=$IMAGE_NAME" --format "table {{.ID}}\t{{.Image}}\t{{.Ports}}"
}

function exec {

    $containers=`docker ps -qf "ancestor=$IMAGE_NAME"`
    if [ `echo $containers | wc -l` -gt 1 ]; then
        echo "Multiple containers running image $IMAGE_NAME found..."
        docker ps -f "ancestor=$IMAGE_NAME" --format "table {{.ID}}\t{{.Image}}\t{{.Ports}}\t{{.Status}}"
    fi

    docker exec -it $containers bash
}

case $1 in
    build)
        build
        ;;
    run)
        run
        ;;
    start)
        start
        ;;
esac