    Phaxio.config do |config|
        config.api_key = Rails.application.secrets.PHAXIO_KEY
        config.api_secret = Rails.application.secrets.PHAXIO_SECRET_KEY
    end