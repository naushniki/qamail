ActiveRecord::Base.connection_pool.with_connection do |connection|
  @pg_listen_connection = connection.instance_variable_get(:@connection)
end

streams = Array.new

get '/listen_to_mailbox' do
  @mailbox = Session.where(:session_key => params[:session_key]).first.mailboxes.where(:address => params[:address]).first
  if @mailbox = nil then
    status 404
    erb :oops
  else 
    streams <<  stream do out
      listen_query = 'listen "' +  @mailbox.address.to_s + '"'
      @pg_listen_connection.execute(listen_query)
      conn.wait_for_notify do
        out.puts 'new'
      end
    end
  end
end
