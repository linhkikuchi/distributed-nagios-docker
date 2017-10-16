#!/bin/bash

# update nagios latest config and restart current container

# check out the latest config from git
cd /nagios-data/ansible-monitor-docker
git_commit=`git rev-parse --verify HEAD`
git pull
# check whether config has no error
output=`docker exec $(docker ps -q --filter ancestor=nagios) /usr/sbin/nagios -v /etc/nagios/nagios.cfg`
echo $output
check_error=`echo "$output" | grep "Total Errors:"`
echo $check_error
# restart the container if pre-flight check has no error
if [ "$check_error" == "Total Errors:   0" ]; then
	docker restart $(docker ps -q --filter ancestor=nagios)
    # restart nagios api
    check_nagioapi=`netstat -nlpt | grep 6315`
    if [ -z "$check_nagioapi" ]; then
        echo "nagios api not running"
        docker exec $(docker ps -q --filter ancestor=nagios) /etc/nagios/nagios-api/nagios-api -p 6315 -c /var/spool/nagios/cmd/nagios.cmd -s /var/spool/nagios/status.dat -l /var/log/nagios/nagios.log &
    	echo "nagios api has been started"
    else
        echo "nagios api is running"
    fi

else
	echo "pre-flight check have errors. Please check the config! Container not restarted!"
    git reset --hard $git_commit
    exit 1
fi