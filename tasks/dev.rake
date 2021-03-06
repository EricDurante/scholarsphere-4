# frozen_string_literal: true

require 'scholarsphere/cleaner'

namespace :dev do
  desc 'Cleans out the dev environment'
  task clean: 'db:load_config' do
    DatabaseCleaner.clean_with(:truncation)
    Scholarsphere::Cleaner.clean
  end
end
