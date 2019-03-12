#!/bin/bash
sed -i 's/HOSTNAME_PLACEHOLDER/$hostname/g' settings.yml
bundle exec ruby letter_import.rb --docker
