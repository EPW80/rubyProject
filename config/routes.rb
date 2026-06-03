# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users,
             path: 'api/v1',
             path_names: { sign_in: 'login', sign_out: 'logout', registration: 'signup' },
             controllers: {
               sessions: 'api/v1/auth/sessions',
               registrations: 'api/v1/auth/registrations'
             }

  namespace :api do
    namespace :v1 do
      resources :projects do
        member do
          patch :update_status
          get   :activity
        end
      end
    end
  end
end
