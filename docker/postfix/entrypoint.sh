#!/bin/bash

postconf -e "home_mailbox = Maildir/"
postconf -e "mailbox_command = "
postconf -e "myhostname = $hostname"
postconf -e "myorigin = $hostname"
postconf -e "mydestination = localhost.localdomain, localhost, $hostname"
postconf -e "relay_domains = $hostname"
echo "/^\w+\@${hostname//\./\\\.}$/ qamail" > /etc/postfix/wildcard.pcre
service rsyslog restart
postfix start-fg || ( postfix stop && postfix start-fg )
#    && tail -f /var/log/mail.log
