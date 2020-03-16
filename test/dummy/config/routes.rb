# frozen_string_literal: true

Rails.application.routes.draw do
  mount SimpleDrilldown::Engine => '/simple_drilldown'
end
