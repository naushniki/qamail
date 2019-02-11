class AddIndexesOnSessionKeyAndAddress < ActiveRecord::Migration[4.2]
  def change
    add_index :sessions, :session_key
    add_index :mailboxes, :address
  end
end
