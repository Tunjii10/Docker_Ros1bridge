!/usr/bin/env bash

XAUTH=/tmp/.docker.xauth
if [ ! -f $XAUTH ]
then
    xauth_list=$(xauth nlist $DISPLAY)
    xauth_list=$(sed -e 's/^..../ffff/' <<< "$xauth_list")
    if [ ! -z "$xauth_list" ]
    then
        echo "$xauth_list" | xauth -f $XAUTH nmerge -
    else
        touch $XAUTH
    fi
    chmod a+r $XAUTH
fi

docker run -it \
    --rm \
    --name ubuntu_20_ros1_bridge \
    -e DISPLAY \
    -e QT_X11_NO_MITSHM=1 \
    -e XAUTHORITY=$XAUTH \
    -v "$XAUTH:$XAUTH" \
    -v "/tmp/.X11-unix:/tmp/.X11-unix" \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/dev/input:/dev/input" \
    --privileged \
    --security-opt seccomp=unconfined \
    --network host \
    ubuntu_20_ros1_bridge:latest


    # docker run -it \
    # --rm \
    # --name ubuntu_20_ros1_bridge \
    # -e DISPLAY \
    # -e QT_X11_NO_MITSHM=1 \
    # -e XAUTHORITY=$XAUTH \
    # -v "$XAUTH:$XAUTH" \
    # -v "/tmp/.X11-unix:/tmp/.X11-unix" \
    # -v "/etc/localtime:/etc/localtime:ro" \
    # -v "/dev/input:/dev/input" \
    # -v "/home/favour/docker_images/ubuntu20/volume:/home/blue/" \
    # --privileged \
    # --security-opt seccomp=unconfined \
    # --network host \
    # ubuntu_20_ros1_bridge:latest


