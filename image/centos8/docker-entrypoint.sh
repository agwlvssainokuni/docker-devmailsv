#!/bin/bash
# -*- coding: utf-8 -*-
#
#  Copyright 2020,2021 agwlvssainokuni
#
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#

exec_supervisord() {
    exec /usr/bin/supervisord -c /etc/supervisord.conf
}

[[ -f /.initialized ]] && exec_supervisord

########################################################################
# (1) SSH HOST KEY
(cd /etc/ssh && rm -f ssh_host_*_key{,.pub})
ssh-keygen -A

########################################################################
# (2) SERVER CERTIFICATE FOR POSTFIX AND DOVECOT
if [[ ! (-f /devmailsv-cert.pem && -f /devmailsv-key.pem) ]]; then
    (cd / && /opt/createcert.sh)
fi

########################################################################
# (3) POSTFIX CONFIGURATION
# (3)-1 /etc/postfix/main.cf
sed -i_DIST \
    -e 's/^\(inet_interfaces = \)/## \1/' \
    -e 's/^\(mynetworks = \)/## \1/' \
    -e 's/^\(smtpd_tls_cert_file *= *\)/## \1/' \
    -e 's/^\(smtpd_tls_key_file *= *\)/## \1/' \
    /etc/postfix/main.cf
cat <<__END_OF_CFG__ >> /etc/postfix/main.cf

########################################
# DEV MAIL SERVER CONFIGURATION
# (0) BASE
inet_interfaces = all
home_mailbox = Maildir/
# (1) ALLOW RELAY
mynetworks = 0.0.0.0/0
# (2) FORCE LOCAL DELIVERY
transport_maps = hash:/etc/postfix/transport
# (3) DISCARD UNKNOWN RECIPIENT
fallback_transport = discard: UNKNOWN RECIPIENT
# (4) ENABLE TLS
smtpd_use_tls = yes
smtpd_tls_cert_file = /devmailsv-cert.pem
smtpd_tls_key_file = /devmailsv-key.pem
# (5) ENABLE SMTP AUTH
smtpd_sasl_auth_enable = yes
smtpd_sasl_type = dovecot
smtpd_sasl_path = private/auth
__END_OF_CFG__

# (3)-2 /etc/postfix/transport
cat <<__END_OF_CFG__ >> /etc/postfix/transport
########################################
# FORCE LOCAL DELIVERY
*   local:\$myhostname
__END_OF_CFG__
postmap /etc/postfix/transport

# (3)-3 /etc/postfix/master.cf
sed -i_DIST \
    -e 's/^#\(submission \)/\1/' \
    -e 's/^#\(  -o syslog_name=postfix\/submission\)/\1/' \
    -e 's/^#\(smtps \)/\1/' \
    -e 's/^#\(  -o syslog_name=postfix\/smtps\)/\1/' \
    -e 's/^#\(  -o smtpd_tls_wrappermode=yes\)/\1/' \
    /etc/postfix/master.cf

########################################################################
# (4) DOVECOT CONFIGURATION
# (4)-1 /etc/dovecot/conf.d/10-ssl.conf
sed -i_DIST \
    -e 's/^\(ssl_cert =\)/## \1/' \
    -e 's/^\(ssl_key =\)/## \1/' \
    /etc/dovecot/conf.d/10-ssl.conf

# (4)-2 /etc/dovecot/conf.d/19-devmailsv.conf
cat <<__END_OF_CFG__ > /etc/dovecot/conf.d/19-devmailsv.conf
########################################
# DEV MAIL SERVER CONFIGURATION
# (1) /etc/dovecot/conf.d/10-mail.conf
mail_location = maildir:~/Maildir
# (2) /etc/dovecot/conf.d/10-master.conf
service auth {
  unix_listener /var/spool/postfix/private/auth {
    mode = 0666
    user = postfix
    group = postfix
  }
}
# (3) /etc/dovecot/conf.d/10-ssl.conf
ssl_cert = </devmailsv-cert.pem
ssl_key = </devmailsv-key.pem
__END_OF_CFG__

########################################################################
# (5) SUPERVISORD CONFIGURATION
sed -i_DIST \
    -e 's/^\(nodaemon=\)/;; \1/' \
    /etc/supervisord.conf
cat <<__END_OF_CFG__ > /etc/supervisord.d/00-devmailsv.ini
[supervisord]
nodaemon=true
[program:rsyslogd]
command=/usr/sbin/rsyslogd -n -iNONE
[program:sshd]
command=/usr/sbin/sshd -D
[program:postfix]
command=/usr/sbin/postfix start-fg
[program:dovecot]
command=/usr/sbin/dovecot -F
__END_OF_CFG__

########################################################################
# (6) EXTRA CONFIGURATION
# (6)-1 ALLOW USER LOGIN
rm -f /run/nologin

# (6)-2 RSYSLOG NOT TO USE JOURNALD
sed -i_DIST \
    -e 's/SysSock.Use="off")/SysSock.Use="on") /' \
    -e 's/^\(module(load="imjournal"\)/## \1) /' \
    -e 's/^\( *StateFile="imjournal.state")\)/## \1) /' \
    /etc/rsyslog.conf

########################################################################
touch /.initialized
newaliases

exec_supervisord
