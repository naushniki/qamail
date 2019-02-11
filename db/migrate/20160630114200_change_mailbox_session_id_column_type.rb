class ChangeMailboxSessionIdColumnType < ActiveRecord::Migration[4.2]
  change_column(:mailboxes, :session_id, 'integer USING CAST(session_id AS integer)')
end
