xml.instruct! :xml, :version => '1.0'
xml.letter do
  xml.id @letter.id
  xml.subject @letter.subject
  xml.from @letter.from
  xml.date @letter.written_at
  xml.raw_content '<pre>'+@letter.raw+'</pre>'  
  if @parsed_letter[:html]!=nil
  	xml.html_content  @parsed_letter[:html]
  end
  if @parsed_letter[:plain_text]!=nil
  	xml.plain_text_content  '<pre>'+@parsed_letter[:plain_text]+'</pre>'
  end
end
