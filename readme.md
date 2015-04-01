QA Mail
=============
QA Mail lets you create unlimited number of disposable mailboxes and read lettres that come into them. It is useful for testing web services that deal with e-mail.
QA mail needs an external mail delivery agent (MDA), configured so that letters to any address on a specific domain will go into one maildir. With Postfix MDA this can be done by setting a pcre table for address rewriting. QA Mail than imports letters from maildir to the database if the address is present in it.

Installation
------------
1. Install postgresql. Create a user, give this user privilage to create databases.
2. Fill settings.yml.example and rename it to settings.yml.
3. 
```
bundle install.
```
4. Start the importer:
```
ruby letter_importer.rb
```
5. Start the web interface:
```
bundle exec puma -e production -d -b unix:///tmp/qamail.sock --pidfile /home/qam/qamail/puma.pid
```

Live demo
------------

http://qamail.ala.se
