class AddIndexOnSessionToMailboxes < ActiveRecord::Migration
  def change
    add_index :mailboxes, :session_id
  end
end
