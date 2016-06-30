class ChangeMailboxSessionIdColumnType < ActiveRecord::Migration
  change_column(:mailboxes, :session_id, 'integer USING CAST(session_id AS integer)')
end
