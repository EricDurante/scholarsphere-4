require 'lograge/sql/extension'

Rails.application.configure do

    config.lograge.custom_options = lambda do |event|
      {
        ip: event.payload[:headers][:REMOTE_ADDR]
      }
    end

    # Instead of extracting event as Strings, extract as Hash. You can also extract
    # additional fields to add to the formatter
    config.lograge_sql.extract_event = Proc.new do |event|
      { name: event.payload[:name], duration: event.duration.to_f.round(2), sql: event.payload[:sql] }
    end
    # Format the array of extracted events
    config.lograge_sql.formatter = Proc.new do |sql_queries|
      sql_queries
    end
end