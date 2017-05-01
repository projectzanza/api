Rails.application.routes.draw do
  mount_devise_token_auth_for 'User', at: 'auth'

  resources :users, only: [:index, :show, :update, :invite, :invited] do
    member do
      post :invite
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
    end

    resources :users, only: [:match, :show] do
      collection do
        get :match
        get :interested
      end
    end
  end
  resources :messages
end
