class AddTimestampToSession < ActiveRecord::Migration[4.2]
  change_table :sessions do |t|
    t.timestamp :created_at
  end
end
