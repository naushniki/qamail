ActiveRecord::Schema.define(version: 20150328010000) do

  enable_extension "plpgsql"

  create_table "mailboxes", force: true do |t|
  t.string  "address"
  t.string  "session_id"
  end

  create_table "sessions", force: true do |t|
  t.string  "session_key"
  end

  create_table "letters", force: true do |t|
  t.integer "mailbox_id"
  t.text "raw"
  t.datetime "writen_at"
  end
  
end
