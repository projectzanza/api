Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :users do
    member do
      post :invite
      post :award
      post :reject
    end

    resources :jobs, only: [:index, :match] do
      collection do
        get :match
      end
    end
  end

  resources :jobs do
    member do
      post :register_interest
      post :accept
    end

    collection do
      get :collaborating
    end

    resources :users, only: [:match, :show] do
      collection do
        get :match
        get :collaborating
      end
    end

    resources :scopes, only: [:index, :create]
  end
  resources :messages

  resources :scopes, only: [:complete] do
    member do
      post :complete
      post :verify
      post :reject
    end
  end
end
