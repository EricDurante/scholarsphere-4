# frozen_string_literal: true

class ResourcesController < ApplicationController
  before_action :load_resource

  def show
    authorize(@resource)
  end

  def download
    if @resource.is_a?(WorkVersion)
      redirect_to_s3
    else
      render file: Rails.root.join('public', '404.html'), status: :not_found
    end
  end

  private

    def load_resource
      @resource = if params[:resource_id]
                    find_resource(params[:resource_id])
                  else
                    find_resource(params[:id])
                  end
    end

    # @todo probably a good idea to make this into a ResourceFinder class
    def find_resource(uuid)
      Work.where(uuid: uuid).first ||
        WorkVersion.where(uuid: uuid).first ||
        raise(ActiveRecord::RecordNotFound)
    end

    def redirect_to_s3
      file = @resource.file_version_memberships.find(params[:id])
      authorize(file)
      redirect_to file.file_resource.file_url(expires_in: ENV.fetch('DOWNLOAD_URL_TTL', 6))
    end
end
