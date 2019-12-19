# frozen_string_literal: true

require 'spec_helper'
require 'support/vcr'
require 'data_cite'

RSpec.describe DataCite::Client do
  subject(:client) { described_class.new }

  let(:valid_metadata) {
    {
      titles: [{ title: 'Work Title' }],
      creators: [{ name: 'Creator' }],
      publicationYear: 2019,
      types: { resourceTypeGeneral: 'Text' },
      url: 'http://example.test'
    }
  }

  describe '#register' do
    context 'when no suffix is provided', :vcr do
      it 'returns the doi as a string and full response as a hash' do
        doi, response_hash = client.register

        expect(doi).to match(/#{client.prefix}\/.+/)
        expect(response_hash.keys).to include('data', 'included')
      end
    end

    context 'when a suffix is provided', :vcr do
      it 'returns the doi with the suffix as a string and full response as a hash' do
        doi, response_hash = client.register('abc123')

        expect(doi).to eq "#{client.prefix}/abc123"
        expect(response_hash.keys).to include('data', 'included')
      end
    end

    context 'when a suffix is provided, but the doi is already taken', :vcr do
      it 'raises an error' do
        expect {
          2.times { client.register('abc456') }
        }.to raise_error(
          DataCite::Client::Error,
          /This DOI has already been taken/
        )
      end
    end
  end

  describe '#publish' do
    context 'when no doi is given', :vcr do
      it 'mints and publishes a new doi' do
        doi, response_hash = client.publish(metadata: valid_metadata)

        expect(doi).to match(/#{client.prefix}\/.+/)
        expect(response_hash.dig('data', 'attributes', 'state')).to eq 'findable'
      end
    end

    context 'when a doi is given', :vcr do
      let(:suffix) { 'abc794' }

      it 'updates and publishes the existing doi' do
        existing_doi, registration_response = client.register(suffix)
        expect(registration_response.dig('data', 'attributes', 'state')).to eq 'draft'

        doi, response_hash = client.publish(doi: existing_doi, metadata: valid_metadata)
        expect(doi).to eq existing_doi
        expect(response_hash.dig('data', 'attributes', 'state')).to eq 'findable'
      end
    end

    context 'when called multiple times with the same doi', :vcr do
      let(:suffix) { 'abc891' }

      it 'can be idempotentently called multiple times, to update metadata', :vcr do
        # Register a draft DOI
        existing_doi, registration_response = client.register(suffix)
        expect(registration_response.dig('data', 'attributes', 'state')).to eq 'draft'

        # Publish that DOI with one set of metadata
        doi, response_hash = client.publish(doi: existing_doi, metadata: valid_metadata)
        expect(doi).to eq existing_doi
        expect(response_hash.dig('data', 'attributes', 'state')).to eq 'findable'

        # "Publish" that DOI again with updated metadata
        updated_metadata = valid_metadata.merge(titles: [{ title: 'Updated Title' }])
        update_doi, update_response_hash = client.publish(doi: existing_doi, metadata: updated_metadata)
        expect(update_doi).to eq existing_doi
        expect(update_response_hash.dig('data', 'attributes', 'state')).to eq 'findable'
        expect(update_response_hash.dig('data', 'attributes', 'titles', 0, 'title')).to eq 'Updated Title'
      end
    end

    context 'when the metadata is invalid', :vcr do
      it 'raises an error' do
        expect {
          client.publish(metadata: {})
        }.to raise_error(
          DataCite::Client::Error,
          /Can't be blank/
        )
      end
    end
  end

  describe '#update' do
    context 'with a valid doi', :vcr do
      let(:suffix) { 'abc802' }

      it 'updates the metadata' do
        existing_doi, _resp = client.register(suffix)
        doi, response_hash = client.update(doi: existing_doi, metadata: valid_metadata)

        expect(doi).to eq existing_doi
        expect(response_hash.dig('data', 'attributes', 'state')).to eq 'draft'
        expect(response_hash.dig('data', 'attributes', 'titles')).to include('title' => 'Work Title')
      end
    end

    context 'with an invalid doi', :vcr do
      it 'raises an error' do
        expect {
          client.update(doi: 'invalid', metadata: valid_metadata)
        }.to raise_error(
          DataCite::Client::Error,
          /The resource you are looking for doesn't exist/
        )
      end
    end
  end

  describe '#delete' do
    context 'with an existing DRAFT doi', :vcr do
      it 'deletes the doi' do
        draft_doi, _resp = client.register('abc900')
        doi, response_hash = client.delete(doi: draft_doi)

        expect(doi).to be_nil
        expect(response_hash).to be_empty
      end
    end

    context 'with an existing PUBLISHED doi', :vcr do
      it 'raises an error' do
        published_doi, _resp = client.publish(metadata: valid_metadata)

        expect {
          client.delete(doi: published_doi)
        }.to raise_error(
          DataCite::Client::Error,
          /Method not allowed/
        )
      end
    end

    context 'with an invalid doi', :vcr do
      it 'raises an error' do
        expect {
          client.delete(doi: 'bogus')
        }.to raise_error(
          DataCite::Client::Error,
          /The resource you are looking for doesn't exist/
        )
      end
    end
  end
end
