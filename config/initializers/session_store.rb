# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_temp_session',
  :secret      => 'c3117d6834f2b0eda760870fda7ee8df411e9a8846283f1141b937acd4ec832d4262aeda2e71e7961d53ad2aa0b71ab36e04c213af8d3c5747e998f5cd0ee7f5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
