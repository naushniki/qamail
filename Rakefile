namespace :db do

  require 'sinatra/activerecord'
  require 'yaml'

  $settings = YAML.load_file("settings.yml")

  task :create do
  puts 'Creating database...'
    ActiveRecord::Base.establish_connection(
      :adapter  => 'postgresql',
      :host     => $settings['DB_host'],
      :username => $settings['DB_username'],
      :password => $settings['DB_password'],
      :database => 'postgres',
      :encoding => $settings['DB_encoding']
    )

    ActiveRecord::Base.connection.create_database($settings['DB_name'])
    
    require './base.rb'
    require './db/schema.rb'
    require './db/seeds.rb'
  end

  task :migrate do

  end
end
