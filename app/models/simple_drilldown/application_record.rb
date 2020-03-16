# frozen_string_literal: true

module SimpleDrilldown
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
