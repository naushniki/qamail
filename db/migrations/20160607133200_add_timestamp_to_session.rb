class AddTimestampToSession < ActiveRecord::Migration
  change_table :sessions do |t|
    t.timestamp :created_at
  end
end
