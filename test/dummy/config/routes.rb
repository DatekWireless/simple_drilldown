# frozen_string_literal: true

Rails.application.routes.draw do
  mount SimpleDrilldown::Engine => '/simple_drilldown'

  resources(:post_drilldown, only: :index) do
    collection do
      get :excel_export
      get :html_export
    end
  end
  resources :posts
  resources(:user_drilldown, only: :index) do
    collection do
      get :excel_export
      get :html_export
    end
  end
  resources :users
end
