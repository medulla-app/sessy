source "https://rubygems.org"

# Specify your gem's dependencies in sessy.gemspec.
gemspec

gem "puma"

gem "sqlite3"

# Postgres is supported alongside SQLite; used to run the suite on PG locally/CI.
gem "pg"

# Rebuilds the precompiled dashboard CSS (app/assets/builds/sessy.css):
#   bundle exec tailwindcss -i app/assets/tailwind/application.css -o app/assets/builds/sessy.css --minify
gem "tailwindcss-rails", require: false

# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
gem "rubocop-rails-omakase", require: false

# Start debugger with binding.b [https://github.com/ruby/debug]
# gem "debug", ">= 1.0.0"
