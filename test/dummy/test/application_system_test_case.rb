# frozen_string_literal: true

require 'test_helper'

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # driven_by :selenium, using: :headless_chrome, screen_size: [1024, 768]
  driven_by :selenium, using: :headless_chrome, screen_size: [1024, 768]
  Capybara.server = :puma, { Silent: true }
end
