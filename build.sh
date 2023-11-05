#!/bin/bash -xe

set -o errexit

. function.sh

YUM=dnf
RELEASEVER=${RELEASEVER:-9}
# MIRROR_URL=https://mirrors.tuna.tsinghua.edu.cn/centos/8-stream
MIRROR_URL=https://mirrors.aliyun.com/centos-stream/9-stream
arch=${ARCH:-$(uname -m)}

install_wget

rootfs=$(pwd)/rootfs
if [[ -e $rootfs ]]; then
  rm -rf $rootfs
fi

key_rpm=centos-gpg-keys-9.0-23.el9.noarch.rpm
repo_rpm=centos-stream-repos-9.0-23.el9.noarch.rpm

base_url=${MIRROR_URL}/BaseOS/${arch}/os/Packages/

wget $base_url/$repo_rpm
wget $base_url/$key_rpm

mkdir -p $rootfs

rpm --root $rootfs --initdb
rpm --nodeps --root $rootfs -ivh $repo_rpm
rpm --nodeps --root $rootfs -ivh $key_rpm

rpm --root $rootfs --import  $rootfs/etc/pki/rpm-gpg/RPM-GPG-KEY-centosofficial
YUM_CMD="$YUM --forcearch $arch -y --releasever $RELEASEVER --setopt=tsflags='nodocs' --setopt=install_weak_deps=False"

$YUM_CMD --installroot=$rootfs install dnf glibc-minimal-langpack langpacks-en glibc-langpack-en
echo "tsflags=nodocs" >> $rootfs/etc/dnf/dnf.conf

cp /etc/resolv.conf $rootfs/etc/resolv.conf

chroot $rootfs /bin/bash <<EOF
$YUM_CMD install yum glibc-minimal-langpack langpacks-en glibc-langpack-en
dnf clean all
EOF

rm -f $rootfs/etc/resolv.conf

tar -C $rootfs -c . > image-$arch.tar
