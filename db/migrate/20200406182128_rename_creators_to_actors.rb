class WorkVersionCreation < ApplicationRecord; end

class RenameCreatorsToActors < ActiveRecord::Migration[6.0]
  def change
    WorkVersionCreation.delete_all

    remove_reference :work_version_creations, :creator, null: false, foreign_key: true

    rename_table :creators, :actors

    add_reference :work_version_creations, :actor, null: false, foreign_key: true
  end
end
