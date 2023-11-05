#!/bin/bash -xe

set -o errexit

. function.sh

YUM=dnf
RELEASEVER=${RELEASEVER:-8}

rootfs=$(pwd)/rootfs
if [[ -e $rootfs ]]; then
  rm -rf $rootfs
fi

arch=${ARCH:-$(uname -m)}
key_rpm=centos-gpg-keys-8-6.el8.noarch.rpm
repo_rpm=centos-stream-repos-8-6.el8.noarch.rpm

# https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream
MIRROR_URL=https://mirrors.aliyun.com/centos/8-stream

base_url=${MIRROR_URL}/BaseOS/${arch}/os/Packages/

install_wget

wget $base_url/$repo_rpm
wget $base_url/$key_rpm

mkdir -p $rootfs

rpm --root $rootfs --initdb
rpm --nodeps --root $rootfs -ivh $repo_rpm
rpm --nodeps --root $rootfs -ivh $key_rpm

rpm --root $rootfs --import  $rootfs/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial

$YUM --forcearch $arch -y --releasever $RELEASEVER --installroot=$rootfs --setopt=tsflags='nodocs' \
    --setopt=install_weak_deps=False \
    install dnf glibc-minimal-langpack langpacks-en glibc-langpack-en
echo "tsflags=nodocs" >> $rootfs/etc/dnf/dnf.conf

cp /etc/resolv.conf $rootfs/etc/resolv.conf

chroot $rootfs /bin/bash <<EOF
dnf -y install --releasever $RELEASEVER yum
dnf clean all
EOF


rm -f $rootfs/etc/resolv.conf

tar -C $rootfs -c . > image-$arch.tar
