require 'sqlite3'
require 'faker'
require 'bcrypt'

# Database setup
db_file = 'random_users.db'
begin
  db = SQLite3::Database.new(db_file)
  db.execute('CREATE TABLE IF NOT EXISTS users (username TEXT PRIMARY KEY, password TEXT)')
rescue SQLite3::Exception => e
  puts "Error creating database or table: #{e.message}"
  exit(1)
end

# Upgrading faker is recommended, but if you can't, use this function:
def generate_strong_password(length = 12)
  characters = [*'0'..'9', *'a'..'z', *'A'..'Z', *'!@#$%^&*()_+=-`~[]\{}|;\':",./<>?']
  (0...length).map { characters.sample }.join
end

100.times do
  begin # Wrap each user creation in a try-except
    username = Faker::Internet.username(specifier: 8..12)

    # Try upgrading faker first. If it fails, use manual generation:
    begin
      password = Faker::Internet.password(min_length: 10, max_length: 20, mixcase: true, special: true)
    rescue ArgumentError # Handles older faker versions
      password = generate_strong_password(12)
      puts "Warning: Using fallback password generation (upgrade faker for better options)."
    end

    hashed_password = BCrypt::Password.create(password)

    db.execute('INSERT INTO users (username, password) VALUES (?, ?)', [username, hashed_password])
    puts "User #{username} created."
  rescue SQLite3::Exception => e
    puts "Error creating user: #{e.message}" # More general error message
  end
end

puts "Finished (or encountered errors) creating 100 random users and passwords." # More descriptive message

db.close