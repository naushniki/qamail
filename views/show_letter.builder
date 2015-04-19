xml.instruct! :xml, :version => '1.0'
xml.letter do
  xml.id @letter.id
  xml.subject @letter.subject
  xml.from @letter.from
  xml.date @letter.written_at
  xml.content @letter.raw
end
