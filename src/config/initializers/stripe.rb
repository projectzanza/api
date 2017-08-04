raise 'STRIPE_API_KEY env var is missing. Do you have your .env set up correctly?' unless ENV['STRIPE_API_KEY']
Stripe.api_key = ENV['STRIPE_API_KEY']
