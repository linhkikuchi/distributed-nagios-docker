#!/bin/bash

# Rebuild nagios container
# check out the latest config from git
cd /nagios-data/ansible-monitor-docker 
git_commit=`git rev-parse --verify HEAD`
git pull
# check whether config has no error
check_error=`docker exec $(docker ps -q --filter ancestor=nagios) /usr/sbin/nagios -v /etc/nagios/nagios.cfg | grep "Total Errors:"`
echo $check_error
# restart the container if pre-flight check has no error
if [ "$check_error" == "Total Errors:   0" ]; then
    cd /var/docker/nagios && ./getLatestDockerBuildFiles.sh && docker build -t nexus/nagios .
    #push to nexus:8443
    docker push nexus:8443/nagios    
else
	echo "pre-flight check have errors. Please check the config! Container not restarted!"
    git reset --hard $git_commit
    exit 1
fi

# Stop old nagios container and launch new container
# stop old container
docker stop $(docker ps -q --filter ancestor=nagios) 
# tag the new image as nagios
docker tag nexus:8443/nagios nagios
# start new container with latest nagios image
docker run --add-host=smtp.globalbrain.net:10.20.30.50 -v /nagios-data/nagios:/etc/nagios -v /nagios-data/log:/var/log/nagios -v /nagios-data/spool:/var/spool/nagios -v /nagios-data/mod_gearman:/etc/mod_gearman -v /nagios-data/mod_gearman_log:/var/log/mod_gearman -v /nagios-data/SLI_RABBITMQ_CONSUMER:/tmp/SLI_RABBITMQ_CONSUMER -p 8080:80 -p 4730:4730 -p 6315:6315 --restart always --hostname=nagios-chc.sli.io -d nagios

# start nagios api
    check_nagioapi=`netstat -nlpt | grep 6315`
    if [ -z "$check_nagioapi" ]; then
        echo "nagios api not running"
        docker exec $(docker ps -q --filter ancestor=nagios) /etc/nagios/nagios-api/nagios-api -p 6315 -c /var/spool/nagios/cmd/nagios.cmd -s /var/spool/nagios/status.dat -l /var/log/nagios/nagios.log &
    	echo "nagios api has been started"
    else
        echo "nagios api is running"
    fi