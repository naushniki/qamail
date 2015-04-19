xml.instruct! :xml, :version => '1.0'
xml.mailbox do
  xml.address @mailbox.address
  @mailbox.letters.each do |letter|
    xml.letter do
    	xml.id letter.id
      xml.subject letter.subject
      xml.from letter.from
      xml.date letter.written_at
    end
  end
end
