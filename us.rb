require 'net/http'
require 'uri'
require 'json' # If you want to work with JSON responses (optional)

# URL of your Sinatra web app
WEB_APP_URL = 'http://localhost:4567/submit'  # Replace with your actual URL if different

def generate_random_number(length = 10)
  rand(10**length).to_s.rjust(length, '0')
end

def create_user(username, number)
  uri = URI.parse(WEB_APP_URL)
  response = Net::HTTP.post_form(uri, { 'username' => username, 'number' => number })

  if response.code == '200' # Check for successful response (HTTP 200 OK)
    puts "User #{username} created successfully."
    # Optionally parse JSON response if your web app returns JSON:
    # begin
    #   json_response = JSON.parse(response.body)
    #   puts "Response: #{json_response}"
    # rescue JSON::ParserError => e
    #   puts "Error parsing JSON response: #{e.message}"
    # end
  else
    puts "Error creating user #{username}: #{response.code} - #{response.body}"
  end
end

100.times do |i|
  username = "user#{i + 1}" # Or generate more random usernames
  number = generate_random_number(10)

  create_user(username, number)
  sleep(0.1) # Optional: Add a small delay to avoid overwhelming the web app
end

puts "Finished creating 100 users."