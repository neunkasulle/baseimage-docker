#!/bin/bash
set -e
source /build/buildconfig
set -x

## Install init process.
cp /build/bin/my_init /sbin/
mkdir -p /etc/my_init.d/start
mkdir -p /etc/my_init.d/stop
mkdir -p /etc/container_environment
touch /etc/container_environment.sh
touch /etc/container_environment.json
chmod 700 /etc/container_environment

groupadd -g 8377 docker_env
chown :docker_env /etc/container_environment.sh /etc/container_environment.json
chmod 640 /etc/container_environment.sh /etc/container_environment.json
ln -s /etc/container_environment.sh /etc/profile.d/

## Basic tools
$minimal_apt_get_install net-tools wget iputils-ping tcpdump netcat dnsutils

## Install runit.
$minimal_apt_get_install runit

## Install datadog monitoring
echo 'deb http://apt.datadoghq.com/ stable main' > /etc/apt/sources.list.d/datadog.list
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 C7A7DA52
apt-get update
$minimal_apt_get_install datadog-agent
$minimal_apt_get_install python-setuptools
easy_install supervisor
sed -i "/user=dd-agent/d" /etc/dd-agent/supervisor.conf
cp /build/90_datadog.sh /etc/my_init.d/start/90_datadog.sh
cp /build/runit/datadog-agent /opt/datadog-agent/runit
chmod +x /opt/datadog-agent/runit
rm /etc/apt/sources.list.d/datadog.list
apt-get update

## Install a syslog daemon.
$minimal_apt_get_install syslog-ng-core
mkdir /etc/service/syslog-ng
cp /build/runit/syslog-ng /etc/service/syslog-ng/run
mkdir -p /var/lib/syslog-ng
cp /build/config/syslog_ng_default /etc/default/syslog-ng
# Replace the system() source because inside Docker we
# can't access /proc/kmsg.
sed -i -E 's/^(\s*)system\(\);/\1unix-stream("\/dev\/log");/' /etc/syslog-ng/syslog-ng.conf

## Install logrotate.
$minimal_apt_get_install logrotate

## Install the SSH server.
$minimal_apt_get_install openssh-server
mkdir /var/run/sshd
mkdir /etc/service/sshd
cp /build/runit/sshd /etc/service/sshd/run
cp /build/config/sshd_config /etc/ssh/sshd_config
cp /build/01_regen_ssh_host_keys.sh /etc/my_init.d/start/01_regen_ssh_host_keys.sh

## Install default SSH key for root and app.
mkdir -p /root/.ssh
chmod 700 /root/.ssh
chown root:root /root/.ssh
cp /build/insecure_key.pub /etc/insecure_key.pub
cp /build/insecure_key /etc/insecure_key
chmod 644 /etc/insecure_key*
chown root:root /etc/insecure_key*
cp /build/bin/enable_insecure_key /usr/sbin/

## Install cron daemon.
$minimal_apt_get_install cron
mkdir /etc/service/cron
cp /build/runit/cron /etc/service/cron/run

## Remove useless cron entries.
# Checks for lost+found and scans for mtab.
rm -f /etc/cron.daily/standard
