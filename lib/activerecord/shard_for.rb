require 'active_record'
require 'expeditor'
require 'activerecord/shard_for/version'
require 'activerecord/shard_for/config'
require 'activerecord/shard_for/cluster_config'
require 'activerecord/shard_for/model'
require 'activerecord/shard_for/errors'
require 'activerecord/shard_for/cluster_router'
require 'activerecord/shard_for/hash_modulo_router'
require 'activerecord/shard_for/database_tasks'
require 'activerecord/shard_for/shard_repogitory'
require 'activerecord/shard_for/all_shards_in_parallel'
require 'activerecord/shard_for/replication_mapping'
require 'activerecord/railtie' if defined?(Rails5)

module ActiveRecord
  module ShardFor
    class << self
      # @return [Activerecord::ShardFor::Config]
      def config
        @config ||= Config.new
      end

      # @yield [Activerecord::ShardFor::Config]
      def configure(&block)
        config.instance_eval(&block)
      end
    end
  end
end

ActiveRecord::ShardFor.config.register_cluster_router(:hash_modulo, ActiveRecord::ShardFor::HashModuloRouter)
