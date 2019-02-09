require "sinatra/json"

def build_json(view)
  case view
  when :show_session
    body = {
      :session => {
        :session_key => @session.session_key,
        :mailboxes => @session.mailboxes.sort{ |a, b| b.id <=> a.id }.map { |mailbox| { :address => mailbox.address } }
      }
    }
  when :show_rendered_letter
    body = {
      :letter => {
        :id => @letter.id,
        :subject => @letter.subject,
        :from => @letter.from,
        :date => @letter.written_at,
        :raw_content => @letter.raw,
        :parsed_letter => {
          :html_content => @parsed_letter[:html],
          :plain_text_content => @parsed_letter[:plain_text]
        }
      }
    }
  when :show_letter
    body = {
      :letter => {
        :id => @letter.id,
        :subject => @letter.subject,
        :from => @letter.from,
        :date => @letter.written_at,
        :content => @letter.raw,
      }
    }
  when :show_mailbox
    body = {
      :mailbox => {
        :address => @mailbox.address,
        :letters => @mailbox.letters.select([:id, :from, :subject, :written_at]).order(written_at: :desc)
          .map { |letter| {
            :id => letter.id,
            :subject => letter.subject,
            :from => letter.from,
            :date => letter.written_at
          } },
        :forwarding_addresses => @mailbox.forwarding_addresses.select([:address]).map {|address| {
            :address => address.address
          }}
      }
    }
  end

  json body
end
