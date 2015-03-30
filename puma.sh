(kill $(cat /home/qam/qamail/puma.pid) && cd /home/qam/qamail && bundle exec puma -e production -d -b unix:///tmp/qamail.sock --pidfile /home/qam/qamail/puma.pid)
