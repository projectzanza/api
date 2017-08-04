raise 'STRIPE_API_KEY env var is missing' unless ENV['STRIPE_API_KEY']
Stripe.api_key = ENV['STRIPE_API_KEY']
