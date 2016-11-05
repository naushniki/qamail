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
  email_regex = %r{([\w\d\-\.]+)@{1}(([\w\d\-]{1,67})|([\w\d\-]+\.[\w\d\-]{1,67}))\.(([a-zA-Z\d]{2,4})(\.[a-zA-Z\d]{2})?)}
  belongs_to :mailbox
  validates_format_of :address, :with => email_regex
  validates :address, uniqueness: { scope: :mailbox_id } , :case_sensitive => false
end
