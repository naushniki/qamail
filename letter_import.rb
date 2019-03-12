require './base.rb'

def forefround_mode
  return ARGV.include?('--fg')
end

def docker
  return ARGV.include?('--docker')
end

if docker
  puts "Letter importer has started in docker compatibility mode"
  STDOUT.sync = true
  log = Logger.new STDOUT
elsif foreground_mode
  puts "Letter importer has started in foreground mode"
  log = Logger.new STDOUT
else
  puts "Letter importer is daemonizing"
  log = Logger.new ($settings['app_root_directory'] + "/log/import.log")
  Process.daemon
end

def kill_existing_process
    f = File.open("letter_import.pid", "r")
  begin
    pid = f.readline
    f.close
  rescue EOFError
    f.close
    return
  end

  if pid.to_i == Process.pid
    return
  else
    log.info("Killing process " + pid)
    system ("kill -9 " + pid) 
  end
end

def delivery_settings
  if $settings["outgoing_mail_delivery_method"] == "smtp"
    options = {
      :address => $settings["smtp_server_hostname"],
      :port => $settings["smtp_port"],
      :domain => $settings["domain"],
      :authentification => nil,
      :enable_starttls_auto => false
    }
    return :smtp, options
  else
    return $settings["outgoing_mail_delivery_method"], nil
  end     
end

kill_existing_process
pidfile = File.new(($settings['app_root_directory'] + "/letter_import.pid"),  "w")
pidfile.truncate(0)
pidfile.write(Process.pid)
pidfile.close

def forward_letter(letter, log)
  letter.mailbox.forwarding_addresses.each do |address|
    log.info("Forwarding letter to #{address.address}")
    forwarded_letter = OutgoingLetter.new
    parsed_letter = Mail.read_from_string(letter.raw)
    parsed_letter.to = address.address
    forwarded_letter.raw = parsed_letter.to_s
    forwarded_letter.mailbox = letter.mailbox
    forwarded_letter.from = letter.mailbox.address
    forwarded_letter.to = address.address
    forwarded_letter.is_forwarded = true
    forwarded_letter.subject = parsed_letter.subject
    forwarded_letter.written_at = Time.now
    forwarded_letter.save
  end
end

import_thread = Thread.new do
  dir = $settings['maildir'] + "/new"
  Dir.chdir(dir)
  while(1 == 1) do
    Dir.foreach(".") do |file|
      begin
        next if (file.start_with?(".") or file.end_with?(".bad"))
        log.info("Found new letter file: #{file}")
        parsed_letter = Mail.read(file)
        attachments_info = String.new
        if parsed_letter.attachments.count > 0
          log.info("This letter has attachments")
          attachments_info << "\nThis letter originally had attachments:\n"
          parsed_letter.attachments.each do |a|
            attachments_info << a.filename + "\n"
          end
        end
        raw = parsed_letter.without_attachments!.to_s + attachments_info
        to_address = Array(parsed_letter.header['X-Original-To'])[0].value
        mailbox = Mailbox.where('lower(address) = ?', to_address.downcase).first
        if mailbox == nil
          log.info("Mailbox not found in the database: #{to_address}. This letter was not imported. Deleting file. #{file}")
          File.delete(file)
          break
        end
        subject = parsed_letter.subject
        from = parsed_letter.from.first
        written_at = parsed_letter.date
        letter = Letter.new
        letter.raw = raw
        letter.mailbox_id = mailbox.id
        letter.from = from
        letter.written_at = written_at
        letter.subject = subject
        letter.save
        log.info("Letter subject is #{letter.subject}")
        log.info("This letter is for #{mailbox.address}")
        log.info("Letter imported. Deleting file #{file}")
        File.delete(file)
        notify_query = 'notify "' + mailbox.address + '"'
        log.info("Executing notify query: #{notify_query}")
        ActiveRecord::Base.connection.execute(notify_query)
      rescue Exception => e
        log.error("Failed to parse file #{file} : #{e.message}")
        log.info("Marking file #{file} as .bad")
        File.rename(file, file+".bad")
      end
      begin        
        forward_letter(letter, log)
      rescue Exception => e
        log.error("Failed to forward letter : #{e.message}")
      end

    end
    sleep(0.1)
  end
end

send_thread = Thread.new do
  letters = Array.new
  while 1==1
    if letters.count>0
      letters = letters + OutgoingLetter.where('sent_at is null and id not in (?)', letters.map{|l| l.id}).order("written_at asc").to_a
    else
      letters = OutgoingLetter.where('sent_at is null').order("written_at asc").to_a
    end

    #Try to send letters, that we did not attempt to send in the last 15 minutes
    letters.select{|l| (l.send_attempts==0 or l.last_delivery_attempt_time == nil or l.last_delivery_attempt_time < Time.now - 900) and l.send_attempts<=672}.each do |letter|
      begin
        mail = Mail.read_from_string(letter.raw)
	method, options = delivery_settings 
        mail.delivery_method(method, options)
        mail.deliver
        letter.sent_at = Time.now
        letter.save
        log.info "Letter \"#{letter.subject}\" sent successfully"
      rescue Exception => e
        log.info "Couldn\'t send \"#{letter.subject}\""
        log.info "DELIVERY ERROR: " +  e.message
        letter.send_attempts+=1
        letter.last_delivery_attempt_time = Time.now
      end
    end
    letters.delete_if { |l| l.sent_at != nil }
    sleep(1.0)
  end
end

import_thread.join
send_thread.join
