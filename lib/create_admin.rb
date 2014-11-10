# usage:
#   rails runner lib/create_admin.rb

# WARNING: everytime this is run it will delete any existing "users" index and recreate it,
#          so typically this is run only once, i.e. upon initial app installation.

begin
  # puts "Elasticsearch::Persistence.client:\n#{Elasticsearch::Persistence.client.inspect}"
  User.create_user_index
  sleep 2
  # a simple match only works here coz the username field is not analyzed/tokenized in elasticsearch:
  admins = User.search(query:{match:{username:'admin'}})
  raise Elasticsearch::Transport::Transport::Errors::NotFound if admins.blank?
  raise "Contact your system administrator as more than one user named 'admin' exists, but only one is allowed!" if admins.count > 1
  admin = admins.first
  puts "No seed needed as admin already exists: id is #{admin.id} username is #{admin.username}."
rescue Faraday::ConnectionFailed, Faraday::Error::TimeoutError => ex
  puts "Can not connect to Elasticsearch!\nError: #{ex.class}\n#{ex.message}\n\n"
rescue Elasticsearch::Transport::Transport::Errors::NotFound => ex
  puts "The 'users' index was not found, so it will be created."
  # you may change the email, password, and password_confirmation for the initial admin user:
  #                                                       **************              ********                           ********
  user = User.new(username: 'admin', admin: true, email: 'your@email.com', password: 'changeme', password_confirmation: 'changeme')
  #                                                       **************              ********                           ********
  resp = user.save
  user.auth_token = user.generate_token
  resp = user.save
  if user.errors.any?
    puts "Failed to create the admin User because:"
    user.errors.full_messages.each do |msg|
      puts "\t#{msg}"
    end
    exit(1)
  end
  puts "Created 'users' index then added the initial admin user.\n\n"
rescue Elasticsearch::Transport::Transport::Errors::BadRequest => ex
  puts "BadRequest: invalid syntax!\nError: #{ex.class}\n#{ex.message}\n\n"
rescue => ex
  puts "Failed during the creation of an initial admin user!\nError: #{ex.class}\n#{ex.message}\n\n"
end
