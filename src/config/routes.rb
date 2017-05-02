Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :users do
    member do
      post :invite
      post :award
    end
    collection do
      get :invited
    end
    resources :jobs, only: [:index, :match, :invited] do
      collection do
        get :match
        get :invited
      end
    end
  end

  resources :jobs do
    member do
      post :register_interest
    end

    collection do
      get :interested
      get :awarded
    end

    resources :users, only: [:match, :show, :awarded] do
      collection do
        get :match
        get :interested
        get :awarded
      end
    end
  end
  resources :messages
end
