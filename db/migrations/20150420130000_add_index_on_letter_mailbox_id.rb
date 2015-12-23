class AddIndexOnLetterMailboxId < ActiveRecord::Migration
  def change
    add_index :letters, :mailbox_id
  end
end
