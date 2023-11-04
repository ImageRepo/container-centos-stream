#!/bin/bash -xe

set -o errexit

. function.sh

rootfs=$(pwd)/rootfs

arch=$(uname -m)
key_rpm=centos-gpg-keys-8-6.el8.noarch.rpm
repo_rpm=centos-stream-repos-8-6.el8.noarch.rpm

# https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream
MIRROR_URL=https://mirrors.aliyun.com/centos/8-stream

base_url=${MIRROR_URL}/BaseOS/x86_64/os/Packages/

install_wget

wget $base_url/$repo_rpm
wget $base_url/$key_rpm

mkdir -p $rootfs

rpm --root $rootfs --initdb
rpm --nodeps --root $rootfs -ivh $repo_rpm
rpm --nodeps --root $rootfs -ivh $key_rpm

rpm --root $rootfs --import  $rootfs/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

yum -y --releasever 8 --installroot=$rootfs --setopt=tsflags='nodocs' \
    --setopt=install_weak_deps=False \
    install dnf glibc-minimal-langpack langpacks-en glibc-langpack-en
echo "tsflags=nodocs" >> $rootfs/etc/dnf/dnf.conf

cp /etc/resolv.conf $rootfs/etc/resolv.conf

chroot $rootfs /bin/bash <<EOF
dnf install -y yum
dnf clean all
EOF


rm -f $rootfs/etc/resolv.conf

tar -C $rootfs -c . | docker import - opstool/centos:stream8
