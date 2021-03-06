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
end
