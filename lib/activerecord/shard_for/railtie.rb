module ActiveRecord
  module ShardFor
    # Railtie of activerecord-shard_for
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.expand_path('../../tasks/activerecord_shard_for.rake', __FILE__)
      end
    end
  end
end
