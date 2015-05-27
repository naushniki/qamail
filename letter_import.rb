require './base.rb'

system ("kill -9 $(cat #{($settings['app_root_directory'] + "/letter_import.pid")})")
unless ARGV.include?('--fg') then Process.daemon end
pidfile = File.new(($settings['app_root_directory'] + "/letter_import.pid"),  "w")
pidfile.truncate(0)
pidfile.write(Process.pid)
pidfile.close
log = Logger.new ($settings['app_root_directory'] + "/log/import.log")
dir = $settings['maildir'] + "/new"
Dir.chdir(dir)
while(1 == 1) do
  Dir.foreach(".") do |file|
    next if file.start_with?(".")
    next if system("lsof " + file) != false
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
    to_address = parsed_letter.header['X-Original-To'].value
    mailbox = Mailbox.where(:address => to_address).first
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
  end
  sleep(0.1)
end
