Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :users, only: [:index, :show, :update] do
    resources :jobs, only: [:index, :match] do
      collection do
        get :match
      end
    end
  end

  resources :jobs do
    resources :users, only: [:match] do
      collection do
        get :match
      end
    end
  end
  resources :messages
end
