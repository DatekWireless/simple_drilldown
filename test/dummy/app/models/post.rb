# frozen_string_literal: true

class Post < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  has_many :comments, dependent: :destroy
end
