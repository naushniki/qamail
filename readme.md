QA Mail
=============
QA Mail lets you create unlimited number of disposable mailboxes and read letters that come into them. It is useful for testing web services that deal with e-mail.  
QA mail needs an external mail delivery agent (MDA). The MDA must be configured so that letters to any address on a specific domain will go into one maildir. With Postfix MDA this can be done by setting a pcre table for address rewriting. QA Mail than imports letters from maildir to the database if the address is present in it.

Installation
------------
* Install postgresql. Create a user, give this user privilage to create databases.  
* Fill settings.yml.example and rename it to settings.yml.  
*  Install libraries
```
bundle install.
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

Live demo
------------

http://qamail.ala.se