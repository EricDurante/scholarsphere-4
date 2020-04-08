class Work < ApplicationRecord; end
class User < ApplicationRecord; end

class AddActorIdToUsers < ActiveRecord::Migration[6.0]
  def change
    # Must do this because we can't have any NULLs in the users.actor_id column
    # and therefore must blow all users away first.
    Work.destroy_all
    User.destroy_all

    add_reference :users, :actor, null: false, foreign_key: true
  end
end
