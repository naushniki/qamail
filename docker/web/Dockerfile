FROM phusion/passenger-ruby23:1.0.2

MAINTAINER Vitaly Pryakhin <v.pryakhin@gmail.com>

# Set correct environment variables.
ENV HOME /root

# Enable nginx and Passenger
RUN rm -f /etc/service/nginx/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Create virtual host
COPY docker/web/qamail.conf /etc/nginx/sites-enabled

# Prepare folders
RUN mkdir /home/app/qamail

# Add our app
COPY . /home/app/qamail
RUN chown -R app:app /home/app
WORKDIR /home/app/qamail
RUN su app -c 'bundle install'
COPY settings.yml.example settings.yml

# Clean up when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

CMD su app -c 'sed -i 's/HOSTNAME_PLACEHOLDER/$hostname/g' settings.yml && bundle exec rake db:migrate 2>/dev/null || bundle exec rake db:schema:load db:migrate 2>/dev/null' && /sbin/my_init
