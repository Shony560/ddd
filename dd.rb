require 'sinatra'
require 'sqlite3'

# Helper method to get the database connection (and create it if needed)
def get_db
  if @db.nil? || @db.closed? # Check if the DB is nil or closed.
    db_file = 'user_data.db'
    begin
      @db = SQLite3::Database.new(db_file)
      @db.execute('CREATE TABLE IF NOT EXISTS users (username TEXT PRIMARY KEY, number TEXT)')
    rescue SQLite3::Exception => e
      puts "Error creating database or table: #{e.message}"
      exit(1)
    end
  end
  @db
end

get '/' do
  erb :index
end

post '/submit' do
  username = params[:username]
  number = params[:number]

  begin
    db = get_db # Get the database connection
    db.execute('INSERT INTO users (username, number) VALUES (?, ?)', [username, number])
    "Data submitted successfully!"
  rescue SQLite3::Exception => e
    "Error submitting data: #{e.message}"
  end
end

# Close the database connection only when the app is truly shutting down
at_exit do
  @db.close if !@db.nil? && !@db.closed?
end