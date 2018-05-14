FROM centos:latest

# Install packages, EPEL must come first
RUN yum -y update && yum -y install epel-release
RUN yum -y install wget gd gd-devel wget httpd php gcc make perl tar unzip libcurl-devel \
  nagios-plugins-ifoperstatus nagios-plugins-ifstatus \
  nagios-plugins-all nagios-plugins-nrpe nagios-plugins-apt \
  supervisor mod_ldap 

## install perl modules for nagios plugins

RUN yum -y install perl-Data-Dumper perl-WWW-Curl perl-JSON python-pip perl-devel perl-libwww-perl perl-LWP-Protocol-https perl-Crypt-SSLeay perl-Switch perl-List-Compare perl-Nagios-Plugin perl-DBI perl-DBD-mysql perl-Mail-IMAPClient python-simplejson MySQL-python

# for check_snmp_synology
RUN yum -y install net-snmp net-snmp-utils which

RUN pip install pymongo
RUN pip install suds

# Install mod-gearman
RUN yum -y install gearmand logrotate

RUN cd /tmp && wget ftp://rpmfind.net/linux/Mandriva/devel/cooker/x86_64/media/contrib/release/lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm && rpm -Uvh lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm && rm -rf /tmp/lib64gearman6-0.32-1-mdv2012.0.x86_64.rpm

RUN cd /tmp && wget https://mod-gearman.org/download/v3.0.2/rhel7/x86_64/mod_gearman-3.0.2-1.rhel7.x86_64.rpm && rpm -Uvh mod_gearman-3.0.2-1.rhel7.x86_64.rpm && rm -rf /tmp/mod_gearman-3.0.2-1.rhel7.x86_64.rpm

# COPY the existing plugins to new server
ADD plugins/* /usr/lib64/nagios/plugins/

# add telegram_nagios
RUN pip install argparse pyTelegramBotAPI

# add all script to local/bin
ADD run/* /usr/local/bin/

# supervisor configuration
ADD supervisord.conf /etc/supervisord.conf

# Define data volumes
VOLUME /etc/mod_gearman
VOLUME /var/log/mod_gearman

CMD ["/usr/bin/supervisord"]
