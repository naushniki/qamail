xml.instruct! :xml, :version => '1.0'
xml.session do
  xml.session_key @session.session_key
  @session.mailboxes.sort{ |a, b| b.id <=> a.id }.each do |mailbox|
    xml.mailbox do
      xml.address mailbox.address
    end
  end
end