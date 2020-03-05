# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResourcesController, type: :controller do
  describe '#show' do
    context 'when requesting a Work' do
      let(:work) { create(:work) }

      it 'loads the Work' do
        get :show, params: { id: work.uuid }
        expect(assigns[:resource]).to eq work
      end
    end

    context 'when requesting a WorkVersion' do
      let(:work_version) { create :work_version }

      it 'loads the WorkVersion' do
        get :show, params: { id: work_version.uuid }
        expect(assigns[:resource]).to eq work_version
      end
    end

    context 'when requesting an unknown uuid' do
      it do
        expect {
          get :show, params: { id: 'not-a-valid-uuid' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when the resource is valid, but not publicly accessible' do
      let(:work) { create(:work, :with_no_access) }

      it do
        expect {
          get :show, params: { id: work.uuid }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end
  end

  describe '#download' do
    context 'when requesting a valid file from a work version' do
      let(:work_version) { create(:work_version, :published, :with_files, file_count: 2) }

      it 'redirects to a presigned S3 url' do
        get :download, params: { resource_id: work_version.uuid, id: work_version.file_version_memberships[0].id }
        expect(assigns[:resource]).to eq(work_version)
        expect(response).to be_redirect
      end
    end

    context 'when requesting a non-existent file from a work version' do
      let(:work_version) { create(:work_version, :published, :with_files) }

      it do
        expect {
          get :download, params: { resource_id: work_version.uuid, id: 99 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when requesting an unkown uuid' do
      it do
        expect {
          get :download, params: { resource_id: 'not-a-valid-uuid', id: 1 }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when requesting a file from an unauthorized draft version' do
      let(:work_version) { create(:work_version, :with_files) }

      it do
        expect {
          get :download, params: { resource_id: work_version.uuid, id: work_version.file_version_memberships[0].id }
        }.to raise_error(Pundit::NotAuthorizedError)
      end
    end

    context 'when requesting a file from a work' do
      let(:work) { create(:work, has_draft: false) }

      it 'returns a 404' do
        get :download, params: { resource_id: work.uuid, id: 1 }
        expect(response).to be_not_found
      end
    end
  end
end
