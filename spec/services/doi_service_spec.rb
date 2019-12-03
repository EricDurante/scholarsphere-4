# frozen_string_literal: true

require 'rails_helper'
# require 'webmock/rspec'
# WebMock.disable_net_connect!(allow: 'solr')

RSpec.describe DoiService, type: :service do
  # before(:each) do
  #     data = {
  #         foo: "bar"
  #     }
  #     ENV['DATACITE_URL'] = 'http://datacite'
  #     stub_request(:post, 'http://datacite/dois').
  #       to_return(status: 200, body: data.to_json)
  # end

  let(:work) { build(:work) }
  let(:resource) { build(:work_version, :with_complete_metadata, resource_type: 'Article') }

  describe '.mint' do
    context 'when we need a doi we mint a doi' do
      it 'mints a doi' do
        doi = described_class.new
        minted = doi.mint(resource)
        expect(minted).to have_key('id')
      end
    end
  end
end
