class AddUserInformationToSession < ActiveRecord::Migration[4.2]
  change_table :sessions do |t|
    t.string :ip_address
    t.string :user_agent
  end
end
