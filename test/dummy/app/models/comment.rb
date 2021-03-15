# frozen_string_literal: true

class Comment < ApplicationRecord
  acts_as_paranoid
  belongs_to :post
  belongs_to :user
end
