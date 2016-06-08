class AddUserInformationToSession < ActiveRecord::Migration
  change_table :sessions do |t|
    t.string :ip_address
    t.string :user_agent
  end
end
