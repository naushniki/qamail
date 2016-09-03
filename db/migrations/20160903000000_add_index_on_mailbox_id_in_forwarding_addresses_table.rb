class AddIndexOnMailboxIdInForwardingAddressesTable < ActiveRecord::Migration
  def change
    add_index :forwarding_addresses, :mailbox_id
  end
end
