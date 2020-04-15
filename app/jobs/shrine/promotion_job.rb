# frozen_string_literal: true

require_relative '../clam/clam_job'

class Shrine::PromotionJob < ApplicationJob
  queue_as :shrine

  def perform(record:, name:, file_data:)
    attacher = Shrine::Attacher.retrieve(model: record, name: name.to_sym, file: file_data)
    attacher.atomic_promote
    # TODO put this somewhere else
    ClamJob.perform_later(file_data)
  rescue Shrine::AttachmentChanged, ActiveRecord::RecordNotFound
    # attachment has changed or record has been deleted, nothing to do
  end
end
