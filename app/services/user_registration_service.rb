# frozen_string_literal: true

# @abstract Registers a user from the API by checking the provided Penn State user id against Penn State's identity
# management service via our PennState::SearchService::Client. If the user exists, they are registered the same way as
# if they had logged in, using User.from_omniauth. If the user does not exist, no changes are made and service returns
# nil.

class UserRegistrationService
  # @param [String] uid or access_id of the user, such as jxd123
  # @return [User, nil]
  def self.call(uid: nil)
    new(uid).register
  end

  attr_reader :found_user

  def initialize(uid)
    @found_user = PennState::SearchService::Client.new.userid(uid)
  end

  def register
    return if found_user.nil?

    omniauth = build_authorization_hash
    User.from_omniauth(omniauth)
  end

  private

    def build_authorization_hash
      OmniAuth::AuthHash.new.tap do |auth_hash|
        auth_hash.uid = found_user.user_id
        auth_hash.provider = 'psu'
        auth_hash.info = build_info_hash
      end
    end

    # @note PennState::SearchService does not return any group information, but this would be updated once the user logs
    # into the application.
    def build_info_hash
      OmniAuth::AuthHash::InfoHash.new(
        access_id: found_user.user_id,
        groups: [],
        email: found_user.university_email,
        given_name: found_user.given_name,
        surname: found_user.surname
      )
    end
end
