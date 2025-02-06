require 'sqlite3'
require 'faker'

# Database setup
db_file = 'users_without_bcrypt.db'
begin
  db = SQLite3::Database.new(db_file)
  db.execute('CREATE TABLE IF NOT EXISTS users (username TEXT PRIMARY KEY, password TEXT)')
rescue SQLite3::Exception => e
  puts "Error creating database or table: #{e.message}"
  exit(1)
end

# Password generation function (for when you CANNOT upgrade faker)
def generate_strong_password(length = 12)
  characters = [*'0'..'9', *'a'..'z', *'A'..'Z', *'!@#$%^&*()_+=-`~[]\{}|;\':",./<>?']
  (0...length).map { characters.sample }.join
end

100.times do
  begin
    username = Faker::Internet.username(specifier: 8..12)

    # Try upgrading faker first. If it fails, use manual generation:
    begin
      password = Faker::Internet.password(min_length: 10, max_length: 20, mixcase: true, special: true) # Try modern faker options
    rescue ArgumentError # Catches the error from older faker
      password = generate_strong_password(12)  # Fallback to manual password creation
      puts "Warning: Using fallback password generation (upgrade faker gem for better options)."
    end

    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, password])
    puts "User #{username} created."
  rescue SQLite3::Exception => e
    puts "Error creating user: #{e.message}"
  end
end

puts "Finished (or encountered errors) creating 100 users and passwords."

db.close