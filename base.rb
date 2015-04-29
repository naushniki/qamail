require 'sinatra'
require 'sinatra/activerecord'
require 'yaml'
require './models.rb'
require 'mail'
require 'digest/sha1'

class QAMail < Sinatra::Base
  register Sinatra::ActiveRecordExtension
end

$settings = YAML.load_file("settings.yml")

ActiveRecord::Base.establish_connection(
  :adapter  => 'postgresql',
  :host     => $settings['DB_host'],
  :username => $settings['DB_username'],
  :password => $settings['DB_password'],
  :database => $settings['DB_name'],
  :encoding => $settings['DB_encoding']
)
