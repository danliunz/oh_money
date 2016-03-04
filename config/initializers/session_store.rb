# Be sure to restart your server when you modify this file.

# use 'expire_after: 10.minutes' to set cookie expiry time
Rails.application.config.session_store :cookie_store, key: '_OhMoney_session',
  expire_after: 3.minutes
  