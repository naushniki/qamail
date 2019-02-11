class AddIndexOnSessionToMailboxes < ActiveRecord::Migration[4.2]
  def change
    add_index :mailboxes, :session_id
  end
end
