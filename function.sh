#!/bin/sh

install_wget(){
  if [[ -e /etc/debian_version ]]; then
    apt update
    apt -y install wget dnf rpm
  fi
  if [[ -e /etc/yum.repos.d ]]; then
    yum -y install wget
  fi
}
