#!/usr/bin/env bash

export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

apt-get update && yes | unminimize
apt-get -y upgrade
apt-get -y update

apt-get -y install\
 build-essential\
 binutils-doc\
 cpp-doc\
 gcc-doc\
 g++\
 g++-multilib\
 gdb\
 gdb-doc\
 glibc-doc\
 libblas-dev\
 liblapack-dev\
 liblapack-doc\
 libstdc++-11-doc\
 make\
 make-doc\
 file\
 locales

#apt-get -y install\
# clang\
# clang-11-doc\
# lldb\
# clang-format

locale-gen en_US.UTF-8
export LANG=en_US.UTF-8

apt-get -y install \
	libboost-all-dev

apt-get -y install\
 blktrace\
 linux-tools-generic\
 strace\
 tcpdump\
 htop

apt-get -y install jq wget \
	python3 python3-pip python3-dev python3-setuptools python3-venv

python3 -m pip install -r /autograder/source/requirements.txt

apt-get -y install sudo

apt-get -y install\
 bc\
 curl\
 dc\
 git\
 git-doc\
 man\
 micro\
 nano\
 psmisc\
 sudo\
 wget\
 screen\
 tmux\
 emacs-nox\
 vim\
 jq


# set up libraries
apt-get -y install\
 libreadline-dev\
 locales\
 wamerican\
 libssl-dev


# Install rust
#RUSTUP_HOME=/opt/rust CARGO_HOME=/opt/rust \
#		      bash -c "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sudo -E sh -s -- -y"

# Install go
#mkdir /usr/local/go && wget -O - https://go.dev/dl/go1.21.6.linux-amd64.tar.gz | sudo tar -xvz -C /usr/local

#echo "export CARGO_HOME=/opt/rust" >> /etc/profile
#echo "export RUSTUP_HOME=/opt/rust" >> /etc/profile
#echo "export PATH=$PATH:/opt/rust/bin" >> /etc/profile
#echo "export PATH=$PATH:/usr/local/go/bin" >> /etc/profile

chmod +x "/autograder/source/set_globals"
chmod +x "/autograder/source/run_autograder"

#export CARGO_HOME=/opt/rust
#export RUSTUP_HOME=/opt/rust
#export PATH=$PATH:/opt/rust/bin

#rustup default stable
