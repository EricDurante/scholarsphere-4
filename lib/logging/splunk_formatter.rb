class SplunkFormatter

    def call(severity, timestamp, _progname, message)
        msg = { 
            type: severity,
            time: timestamp,
            message: message
          }.to_json
        "#{msg} \n"
    end

end
