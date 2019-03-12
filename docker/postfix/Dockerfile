FROM debian:testing-20190204-slim

MAINTAINER Vitaly Pryakhin <v.pryakhin@gmail.com>

RUN useradd qamail
RUN mkdir -p /home/qamail
RUN mkdir /home/qamail/Maildir
RUN chown -R qamail:qamail /home/qamail

RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y postfix postfix-pcre rsyslog
RUN postconf -e "virtual_alias_maps = pcre:/etc/postfix/wildcard.pcre"
RUN postconf -e "mynetworks = 10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16, 127.0.0.0/8, localhost"
RUN postconf -M smtp/inet="smtp       inet  n       -       n       -       -       smtpd"
RUN postconf -M smtp/unix="smtp       unix  -       -       n      -       -       smtp"
COPY ./docker/postfix/entrypoint.sh /home/qamail
RUN chmod +x /home/qamail/entrypoint.sh
#TODO: Use stdout for logging after postfix 3.4.0 stable is released
#RUN echo "postlog   unix-dgram n  -       n       -       1       postlogd" >> /etc/postfix/master.cf
#RUN postconf -e "maillog_file  = /dev/stdout"
RUN postfix stop
EXPOSE 25

CMD bash /home/qamail/entrypoint.sh
