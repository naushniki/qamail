class Session < ActiveRecord::Base
  has_many :mailboxes
  validates :session_key, uniqueness: true
end

class Mailbox < ActiveRecord::Base
  has_many :letters
  belongs_to :session
  validates :address, uniqueness: true
end

class IncomingLetter < ActiveRecord::Base
  self.table_name = 'incoming_letters'
  belongs_to :mailbox
end

class Letter < IncomingLetter
end

class OutgoingLetter < ActiveRecord::Base
  belongs_to :mailbox
end
