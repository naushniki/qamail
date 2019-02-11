class AddIndexOnMailboxIdInForwardingAddressesTable < ActiveRecord::Migration[4.2]
  def change
    add_index :forwarding_addresses, :mailbox_id
  end
end
