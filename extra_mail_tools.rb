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
  
end
