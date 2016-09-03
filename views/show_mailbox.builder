xml.instruct! :xml, :version => '1.0'
xml.mailbox do
  xml.address @mailbox.address
  @mailbox.letters.select([:id, :from, :subject, :written_at]).each do |letter|
    xml.letter do
      xml.id letter.id
      xml.subject letter.subject
      xml.from letter.from
      xml.date letter.written_at
    end
  end
  @mailbox.forwarding_addresses.select([:address]).each do |forwarding_address|  
      xml.forwarding_address do
      	xml.address forwarding_address.address
      end
    end
end
