QA Mail
=============
QA Mail lets you create unlimited number of disposable mailboxes and read letters in a cozy web-interface. It is useful for testing web applications that deal with e-mail.  
QA Mail can be used both for manual testing via a web user interface and also for automated testing, using its REST API.

Live demo
------------

http://qamail.ala.se

To Do List
------------

* Asynchronous notifications about new messages
* Message forwarding / replying
* API for autotests

Installation
------------
* Configure the mail delivery agent.  
QA mail needs an external mail delivery agent (MDA). The MDA must be configured so that messages to any address on a specific domain will go into one maildir. Than you should point QA Mail to this Maildir by specifying it in settings.yml.  
If you wish yo use Postfix, its configuration is described in the section "How to configure Postfix to work with QA Mail".
* Install postgresql. Create a user, give this user privilage to create databases.  
* Fill settings.yml.example and rename it to settings.yml.  
*  Install libraries
```
bundle install
```
* Create the DB
```
rake db:create
```
* Start the importer:  
```
ruby letter_import.rb
```
* Start the web interface:  
```
bundle exec puma -e production -d
```


How to configure Postfix to work with QA Mail 
------------

This manual will help you configure Postfix to work with QA Mail on Debian 7.  
First, you should tie your domain name to the IP address of your server. You don't need an MX DNS record, a simple A record is sufficient. If you don't have a domain name, you can get one for free here: http://freedns.afraid.org/  

* Install Postfix  
```
apt-get install postfix postfix-pcre
```
In the dialog choose "Internet site".
Enter your domain.

* Configure Postfix
```
postconf -e "home_mailbox = Maildir/"
postconf -e "mailbox_command = "
```
Edit file /etc/postfix/main.cf  
Add or edit the following lines:
```
myhostname = YOUR_DOMAIN_NAME
myorigin = YOUR_DOMAIN_NAME
mydestination = localhost.localdomain, localhost, YOUR_DOMAIN_NAME
relay_domains = YOUR_DOMAIN_NAME
virtual_alias_maps = pcre:/etc/postfix/wildcard.pcre
```

* Configure address rewriting  
Put the following into the file /etc/postfix/wildcard.pcre:
```
/^\w+\@example\.example\.com$/ qamail
```
This is for domain name example.example.com, change it for your domain name.  

* Restart Postfix
```
/etc/init.d/postfix restart
```

* Add a user, that will run QA Mail
```
adduser qamail
```
Now configure QA Mail. The Maildir, which you should specify in settings.yml is /home/qamail/Maildir/  
QA Mail itself must be run by user qamail.  
Also, make sure that your firewall allows TCP connections to port 25.