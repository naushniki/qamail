class Session < ActiveRecord::Base
  has_many :mailboxes
  validates :session_key, uniqueness: true
end

class Mailbox < ActiveRecord::Base
  has_many :letters
  has_many :outgoing_letters
  has_many :forwarding_addresses
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
  attr_accessor :send_attempts
  attr_accessor :last_delivery_attempt_time
  after_initialize do
    send_attempts=0
    last_delivery_attempt_time=nil
  end
end

class ForwardingAddress < ActiveRecord::Base
  belongs_to :mailbox
end