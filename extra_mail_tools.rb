module ExtraMailTools
  
  def detect_part_encoding(part)
    begin
      tags = part.content_type.split(' ')
    rescue
      return nil
    end
    tags.each do |tag|
      if tag =~ /^charset=/i
        tag.slice! "charset="
        return tag
      else
        next
      end
    end
    return nil
  end
  
  alias_method :detect_letter_encoding, :detect_part_encoding

  def parse_letter(letter)
    parsed_letter={}
    letter = Mail.read_from_string(letter.raw)

    if letter.parts.count == 0
      encoding=detect_letter_encoding(letter)
      if encoding==nil
        encoding='utf-8' #If we cannot detect encoding, we assume it's UTF-8
      end  
      if letter.content_type.include? 'text/html'
        parsed_letter[:html]=letter.body.decoded
        parsed_letter[:html].force_encoding encoding
      elsif letter.content_type.include? 'text/plain'
        parsed_letter[:plain_text]=letter.body.decoded
        parsed_letter[:plain_text].force_encoding encoding
      end
    else
      letter.parts.each do |part|
        encoding=detect_part_encoding(part)
        if encoding==nil
          encoding='utf-8' #If we cannot detect encoding, we assume it's UTF-8
        end
        if part.content_type.include?'text/html'
          parsed_letter[:html]=part.body.decoded
          parsed_letter[:html].force_encoding encoding
        elsif (part.content_type.include?'text/plain')
          parsed_letter[:plain_text]=part.body.decoded
          parsed_letter[:plain_text].force_encoding encoding
        end
      end
    end
    return parsed_letter
  end
end
