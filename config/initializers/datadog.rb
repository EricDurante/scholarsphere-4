# frozen_string_literal: true

if ENV['DD_AGENT_HOST']
  require 'ddtrace'
  Datadog.configure do |c|
    c.use :rails
    c.use :active_record
    c.use :faraday
    c.use :sidekiq
    c.use :redis
    c.tracer env: ENV['DD_ENV']
  end
end
