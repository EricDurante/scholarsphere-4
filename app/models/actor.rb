# frozen_string_literal: true

class Actor < ApplicationRecord
  has_many :work_version_creations,
           dependent: :restrict_with_exception,
           inverse_of: :actor

  has_many :work_versions,
           through: :work_version_creations,
           inverse_of: :actors

  validates :surname,
            presence: true

  def default_alias
    super.presence || "#{given_name} #{surname}"
  end
end
