class AddOutgoingLetters < ActiveRecord::Migration
  def change
    create_table "outgoing_letters", force: true do |t|
      t.integer "mailbox_id"
      t.text "raw"
      t.datetime "written_at"
      t.datetime "sent_at"
      t.string "from"
      t.string "to"
      t.string "subject"
    end

    rename_table :letters, :incoming_letters

  end
end
