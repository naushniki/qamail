class AddIndexOnLetterMailboxId < ActiveRecord::Migration[4.2]
  def change
    add_index :letters, :mailbox_id
  end
end
