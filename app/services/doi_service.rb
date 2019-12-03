# frozen_string_literal: true

require 'faraday'

# TODO perhaps pull this from the database?
DATACITE_RESOURCE_TYPES = {
  'Article' => 'Text',
  'Audio' => 'Sound',
  'Book' => 'Book',
  'Capstone Project' => 'Text',
  'Conference Proceeding' => 'Text',
  'Dataset' => 'Dataset',
  'Image' => 'Image',
  'Journal' => 'Text',
  'Map or Cartographic Material' => 'Image',
  'Part of Book' => 'Text',
  'Poster' => 'Audiovisual',
  'Presentation' => 'Audiovisual',
  'Project' => 'Other',
  'Report' => 'Text',
  'Research Paper' => 'Text',
  'Software or Program Code' => 'Software',
  'Video' => 'Audiovisual',
  'Other' => 'Other'

}.freeze

class DoiService
  def initialize
    @datacite_url = ENV['DATACITE_URL']
    @username = ENV['DATACITE_USERNAME']
    @password = ENV['DATACITE_PASSWORD']
    @prefix = ENV['DATACITE_PREFIX']
    @publisher = ENV.fetch('DATACITE_PUBLISHER', 'scholarsphere')
  end

  def mint(resource)
    data = {
      data: {
        type: 'dois',
        attributes: {
          event: 'publish',
          prefix: @prefix,
          creators: [{
            name: resource.depositor.name
          }],
          titles: [{
            title: resource.title
          }],
          publisher: @publisher,
          publicationYear: Time.new.year,
          types: {
            resourceTypeGeneral: DATACITE_RESOURCE_TYPES[resource.resource_type.first]
          },
          url: resource.related_url.first,
          schemaVersion: 'http://datacite.org/schema/kernel-4'
        }
      }
    }

    connection = Faraday.new(url: @datacite_url) do |conn|
      conn.request :basic_auth, @username, @password
      conn.adapter :net_http
    end

    resp = connection.post('/dois') do |req|
      req.headers['Content-Type'] = 'application/vnd.api+json'
      req.body = data.to_json
    end

    raise resp.body unless resp.success?

    JSON.parse(resp.body)['data']
  end
end
