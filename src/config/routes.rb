Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  # /users
  resources :users do
    member do
      post :invite
      post :award
      post :reject
    end

    # /users/:user_id/jobs
    resources :jobs, only: %i[index] do
      collection do
        get :match
      end
    end

    resources :positions, only: %i[index]
  end

  resources :positions, only: %i[create update destroy]

  # /jobs
  resources :jobs do
    member do
      post :register_interest
      post :accept
      post :complete
      post :verify
    end

    collection do
      get :collaborating
    end

    # /jobs/:job_id/users
    resources :users, only: %i[match show] do
      collection do
        get :match
        get :collaborating
      end
    end

    # /jobs/:job_id/estimates
    resources :estimates, only: [:create]

    # /jobs/:job_id/scopes
    resources :scopes, only: %i[index create]

    # /jobs/:job_id/payments
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

  resources :scopes, only: %i[update destroy] do
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
