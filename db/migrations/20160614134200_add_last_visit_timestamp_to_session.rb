class AddLastVisitTimestampToSession < ActiveRecord::Migration
  change_table :sessions do |t|
    t.timestamp :last_visit
  end
end
