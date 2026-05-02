# frozen_string_literal: true

Rails.application.routes.draw do
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
