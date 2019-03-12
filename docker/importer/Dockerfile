FROM ruby:2.3.8-stretch

MAINTAINER Vitaly Pryakhin <v.pryakhin@gmail.com>

RUN useradd app
RUN mkdir /home/app
RUN mkdir /home/app/qamail
RUN touch /home/app/qamail/letter_import.pid
RUN mkdir /home/app/Maildir
RUN apt-get update

COPY . /home/app/qamail
COPY ./docker/importer/settings.yml /home/app/qamail
COPY ./docker/importer/entrypoint.sh /home/app/qamail
RUN chmod +x /home/app/qamail/entrypoint.sh
RUN chown -R app:app /home/app
USER app
WORKDIR /home/app/qamail
RUN bundle install

CMD /home/app/qamail/entrypoint.sh
