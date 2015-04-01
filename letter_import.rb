require './base.rb'

Process.daemon
system ("kill -9 $(cat #{($settings['app_root_directory'] + "/letter_import.pid")})")
pidfile = File.new(($settings['app_root_directory'] + "/letter_import.pid"),  "w")
pidfile.truncate(0)
pidfile.write(Process.pid)
pidfile.close
log = Logger.new ($settings['app_root_directory'] + "log/import.log")
dir = $settings['maildir'] + "/new"
Dir.chdir(dir)
while(1 == 1) do
  Dir.foreach(".") do |file|
    if file.start_with?(".") then break end
    if system("lsof " + file) != false then break end
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
    to_addresses = parsed_letter.to
    mailbox = Mailbox.where(:address => to_addresses).first
    if mailbox == nil
      log.info("Mailbox not found in the database: #{to_addresses}. This letter was not imported. Deleting file.")
      File.delete(file)
      break
    end
    subject = parsed_letter.subject
    from = parsed_letter.from.first
    written_at = parsed_letter.date
    File.open(file, "r") do |letter_file|
      letter = Letter.new
      letter.raw = raw
      letter.mailbox_id = mailbox.id
      letter.from = from
      letter.written_at = written_at
      letter.subject = subject
      letter.save
      log.info("Letter imported. Deleting file #{letter_file}")
      letter_file.close
      File.delete(letter_file)
    end
  end
  sleep(0.1)
end
