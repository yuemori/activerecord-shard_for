module ActiveRecord
  module ShardFor
    # Railtie of mixed_gauge
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load File.expand_path('../../tasks/activerecord_shard_for.rake', __FILE__)
      end
    end
  end
end
