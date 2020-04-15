# frozen_string_literal: true

class Clam::ClamJob < ApplicationJob
    queue_as :clam
   
    ## Job is performed by clam-listener
    def perform(data)
    end
end
  