require 'active_record'
require 'activerecord/shard_for/version'
require 'activerecord/shard_for/config'
require 'activerecord/shard_for/cluster_config'
require 'activerecord/shard_for/model'
require 'activerecord/shard_for/database_tasks'
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
