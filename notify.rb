require 'sinatra/streaming'

ActiveRecord::Base.connection_pool.with_connection do |connection|
  @pg_listen_connection = connection.instance_variable_get(:@connection)
end

streams = Array.new

get '/listen_to_mailbox', provides: 'text/event-stream' do
  if not $settings['async_notifications']
    status 503
    erb :blank, :layout => :no_css
  else
    @mailbox = Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first
    if @mailbox == nil then
      status 404
      erb :oops
    else 
      stream do |out|
        streams << out
        ActiveRecord::Base.connection_pool.with_connection do |connection|
          pg_listen_connection = connection.instance_variable_get(:@connection)
          listen_query = 'listen "' +  @mailbox.address.to_s + '"'
          pg_listen_connection.exec(listen_query)
          while true
            pg_listen_connection.wait_for_notify
            out.puts "data: new letter\n\n"
          end
          out.callback{out.close}
        end
      end
    end
  end
end
