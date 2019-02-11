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
    end

  namespace :schema do
    task :load do
      require './base.rb'
      require './db/schema.rb'
      require './db/seeds.rb'
    end
  end

  task :migrate do
  
    puts 'Running migrations...'
    require './base.rb'
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
#    ActiveRecord::Migrator.migrations("db/migrations")
    migrations = ActiveRecord::Migration.new.migration_context.migrations
    ActiveRecord::Migrator.new(:up, migrations, nil).migrate   
  end

end
