class AddIndexesOnSessionKeyAndAddress < ActiveRecord::Migration
  def change
    add_index :sessions, :session_key
    add_index :mailboxes, :address
  end
end
