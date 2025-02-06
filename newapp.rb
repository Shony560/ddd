# newapp.rb (INSECURE - FOR DEMONSTRATION ONLY - DO NOT USE IN PRODUCTION)
require 'sinatra'
require 'sqlite3'

enable :sessions

# Database setup
db_file = 'users_without_bcrypt.db' # Use the database with PLAIN TEXT passwords
begin
  db = SQLite3::Database.new(db_file)
rescue SQLite3::Exception => e
  puts "Error opening database: #{e.message}"
  exit(1)
end

def get_db(db_file)
  if @db.nil? || @db.closed?
    begin
      @db = SQLite3::Database.new(db_file)
    rescue SQLite3::Exception => e
      puts "Error opening database: #{e.message}"
      exit(1)
    end
  end
  @db
end

# Routes
get '/' do
  if session[:username]
    erb :welcome, locals: { username: session[:username] }
  else
    erb :login
  end
end

post '/login' do
  username = params[:username]
  password = params[:password]

  begin
    db = get_db(db_file)
    stored_password = db.get_first_value("SELECT password FROM users WHERE LOWER(username) = LOWER(?)", username)

    if stored_password && stored_password == password  # Direct comparison - INSECURE
      session[:username] = username
      redirect '/'
    else
      @error = "Invalid username or password."
      erb :login
    end
  rescue SQLite3::Exception => e
    @error = "Database error: #{e.message}"
    erb :login
  end
end

get '/logout' do
  session.clear
  redirect '/'
end

# Close database on shutdown
at_exit do
  db = get_db(db_file)
  db.close if !db.nil? && !db.closed?
end