style = '
<style>
/* Browser specific (not valid) styles to make preformatted text wrap */

pre {
 white-space: pre-wrap;       /* css-3 */
 white-space: -moz-pre-wrap;  /* Mozilla, since 1999 */
 white-space: -pre-wrap;      /* Opera 4-6 */
 white-space: -o-pre-wrap;    /* Opera 7 */
 word-wrap: break-word;       /* Internet Explorer 5.5+ */
 font-family: monospace;

     }

</style>
'

xml.instruct! :xml, :version => '1.0'
xml.letter do
  xml.id @letter.id
  xml.subject @letter.subject
  xml.from @letter.from
  xml.date @letter.written_at
  xml.raw_content style+"<pre>"+@letter.raw+'</pre>'
  if @parsed_letter[:html]!=nil
  	xml.html_content  @parsed_letter[:html]
  end
  if @parsed_letter[:plain_text]!=nil
  	xml.plain_text_content style+'<pre>'+@parsed_letter[:plain_text]+'</pre>'
  	reply = @parsed_letter[:plain_text][0..999]
    if @parsed_letter[:plain_text].length>1000
      reply << "\n..."
    end
  	xml.plain_text_for_reply reply
  end
end
