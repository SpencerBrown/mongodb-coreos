#!/usr/bin/env bash

OS=${1:-"linux"}
DISTRO=${2:-"debian81"}
RELEASE=${3:-"3.4.4"}
# Local directory to use
LOCAL=${4:-"/opt/bin"}

case $OS in

linux)
    ;;
osx)
    ;;
*)
    echo "get-mongodb.sh OS DISTRO RELEASE LOCAL"
    exit 1
esac

echo Downloading MongoDB $OS $DISTRO $RELEASE

curl -O https://fastdl.mongodb.org/$OS/mongodb-$OS-x86_64-$DISTRO-$RELEASE.tgz
tar xzf mongodb-$OS-x86_64-$DISTRO-$RELEASE.tgz
rm mongodb-$OS-x86_64-$DISTRO-$RELEASE.tgz
sudo mkdir -p $LOCAL
sudo chown core:core $LOCAL
mkdir -p $LOCAL/mongodb-$RELEASE
mv mongodb-$OS-x86_64-$DISTRO-$RELEASE/bin/* $LOCAL/mongodb-$RELEASE
rm -r mongodb-$OS-x86_64-$DISTRO-$RELEASE
cd $LOCAL
ln -snf mongodb-$RELEASE mongodb
