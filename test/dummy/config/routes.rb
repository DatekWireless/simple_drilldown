# frozen_string_literal: true

Rails.application.routes.draw do
  mount SimpleDrilldown::Engine => '/simple_drilldown'

  draw_drilldown :advanced_post
  draw_drilldown :post do
    get :excel_export
    get :html_export
  end
  resources :posts
  draw_drilldown :user
  resources :users
end
