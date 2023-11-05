#!/bin/bash -xe

set -o errexit

. function.sh

YUM=yum
RELEASEVER=${RELEASEVER:-7}
# MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream
arch=${ARCH:-$(uname -m)}
if [[ $arch == 'x86_64' ]]; then
  MIRROR_URL=https://mirrors.aliyun.com/centos/$RELEASEVER
elif [[ $arch == 'aarch64' ]]; then
  MIRROR_URL=https://mirrors.aliyun.com/centos-altarch/$RELEASEVER
else
  echo unknow $arch
  exit 1
fi

install_wget

rootfs=$(pwd)/rootfs
if [[ -e $rootfs ]]; then
  rm -rf $rootfs
fi

release_rpm=centos-release-7-9.2009.0.el7.centos.x86_64.rpm

base_url=${MIRROR_URL}/os/${arch}/Packages/

wget $base_url/$release_rpm

mkdir -p $rootfs

rpm --root $rootfs --initdb
rpm --nodeps --root $rootfs -ivh $repo_rpm
rpm --nodeps --root $rootfs -ivh $key_rpm

rpm --root $rootfs --import  $rootfs/etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

$YUM --forcearch $arch -y --releasever $RELEASEVER --installroot=$rootfs --setopt=tsflags='nodocs' \
    --setopt=install_weak_deps=False \
    install yum glibc
echo "tsflags=nodocs" >> $rootfs/etc/dnf/dnf.conf

tar -C $rootfs -c . > image-$arch.tar
