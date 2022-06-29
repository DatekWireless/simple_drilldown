# frozen_string_literal: true

gems = "#{File.dirname __dir__}/Gemfile"
eval File.read(gems), binding, gems # rubocop: disable Security/Eval

gem 'rails', '~> 6.1.0'
