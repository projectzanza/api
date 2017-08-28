Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :users do
    member do
      post :invite
      post :award
      post :reject
    end

    resources :jobs, only: %i[index match] do
      collection do
        get :match
      end
    end
  end

  resources :jobs do
    member do
      post :register_interest
      post :accept
      post :verify
    end

    collection do
      get :collaborating
    end

    resources :users, only: %i[match show] do
      collection do
        get :match
        get :collaborating
      end
    end

    resources :estimates, only: [:create]

    resources :scopes, only: %i[index create]

    resources :payments do
      collection do
        post :token
        post :complete
      end
    end
  end

  resources :messages

  resources :estimates, only: %i[update create destroy] do
    member do
      post :accept
      post :reject
    end
  end

  resources :scopes, only: [:update] do
    member do
      post :complete
      post :verify
      post :reject
    end
  end

  resources :payments do
    collection do
      get :cards
    end
  end

  resources :rocket_chat do
    collection do
      post :login
    end
  end
end
