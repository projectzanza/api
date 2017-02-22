Rails.application.routes.draw do
  resources :replies
  resources :jobs
  mount_devise_token_auth_for 'User', at: 'auth'
end
