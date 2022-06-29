# frozen_string_literal: true

gems = File.expand_path('../Gemfile', __dir__)
eval File.read(gems), binding, gems # rubocop: disable Security/Eval

gem 'rails', '~> 6.1.0'
