ENV['SINATRA_ACTIVESUPPORT_WARNING'] = 'false'
require 'sinatra'
require 'sinatra/activerecord'
require 'yaml'
require './models.rb'
require 'mail'

class QAMail < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end

$settings = YAML.load_file("settings.yml")
ActiveRecord::Base.logger = nil
ActiveRecord::Base.establish_connection(
  :adapter  => 'postgresql',
  :host     => $settings['DB_host'],
  :username => $settings['DB_username'],
  :password => $settings['DB_password'],
  :database => $settings['DB_name'],
  :encoding => $settings['DB_encoding'],
  :pool => 150
)
