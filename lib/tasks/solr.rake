# frozen_string_literal: true

require 'scholarsphere/solr_admin'

namespace :solr do
  desc 'Delete everything from Solr and create a new configset and collection'
  task reset: :environment do
    Scholarsphere::SolrAdmin.reset
  end

  task init: :environment do
    conf = Scholarsphere::SolrAdmin.new
    conf.upload_config unless conf.configset_exists?
    conf.create_collection unless conf.collection_exists?
    # we always modify collection. it's call is idempotent, and
    # will ensure we have the config bound to the collection
    conf.modify_collection
  end

  desc 'Reindexes all our resources into Solr'
  task reindex: :environment do
    WorkVersion.all.map { |version| IndexingService.call(resource: version) }
    Blacklight.default_index.connection.commit
  end
end
