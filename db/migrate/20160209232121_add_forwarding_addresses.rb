class AddForwardingAddresses < ActiveRecord::Migration[4.2]
  def change
    create_table "forwarding_addresses", force: true do |t|
      t.integer "mailbox_id"
      t.string "address"
    end
    change_table :outgoing_letters do |t|
      t.boolean :is_forwarded
    end
  end
end
