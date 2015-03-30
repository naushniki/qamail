class Session < ActiveRecord::Base
  has_many :mailboxes
  validates :session_key, uniqueness: true
end

class Mailbox < ActiveRecord::Base
  has_many :letters
  belongs_to :session
  validates :address, uniqueness: true
end

class Letter < ActiveRecord::Base
  belongs_to :mailbox
end
