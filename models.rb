class Session < ActiveRecord::Base
  has_many :mailboxes
end

class Mailbox < ActiveRecord::Base
  has_many :letters
  belongs_to :session
end

class Letter < ActiveRecord::Base
  belongs_to :mailbox
end
