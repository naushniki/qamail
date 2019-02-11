class AddLastVisitTimestampToSession < ActiveRecord::Migration[4.2]
  change_table :sessions do |t|
    t.timestamp :last_visit
  end
end
