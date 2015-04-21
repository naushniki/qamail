xml.instruct! :xml, :version => '1.0'
xml.session do
  xml.session_key @session.session_key
  @session.mailboxes.each do |mailbox|
    xml.mailbox do
      xml.address mailbox.address
    end
  end
end