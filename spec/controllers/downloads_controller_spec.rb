# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DownloadsController, type: :controller do
  describe 'GET #content' do
    context 'when requesting a valid file from a work version' do
      let(:work_version) { create(:work_version, :published, :with_files, file_count: 2) }

      it 'redirects to a presigned S3 url' do
        get :content, params: { resource_id: work_version.uuid, id: work_version.file_version_memberships[0].id }
        expect(response).to be_redirect
      end
    end

    context 'when requesting a non-existent file from a work version' do
      let(:work_version) { create(:work_version, :published, :with_files) }

      it do
        expect {
          get :content, params: { resource_id: work_version.uuid, id: 99 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when requesting an unkown uuid' do
      it do
        expect {
          get :content, params: { resource_id: 'not-a-valid-uuid', id: 1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when requesting a file from an unauthorized draft version' do
      let(:work_version) { create(:work_version, :with_files) }

      it do
        expect {
          get :content, params: { resource_id: work_version.uuid, id: work_version.file_version_memberships[0].id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when requesting a file from a work' do
      let(:work) { create(:work, has_draft: false) }

      it do
        expect {
          get :content, params: { resource_id: work.uuid, id: 1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
