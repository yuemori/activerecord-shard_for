require 'active_support/concern'

module ActiveRecord
  module ShardFor
    module Model
      extend ActiveSupport::Concern

      included do
        class_attribute :cluster_router, instance_writer: false
        class_attribute :shard_repository, instance_writer: false
        class_attribute :distkey, instance_writer: false
      end

      module ClassMethods
        # The cluster config must be defined before `use_cluster`
        # @param [Symbol] name A cluster name which is set by ActiveRecord::ShardFor.configure
        def use_cluster(name, router_name)
          cluster_config = ActiveRecord::ShardFor.config.fetch_cluster_config(name)
          cluster_router_class = ActiveRecord::ShardFor.config.fetch_cluster_router(router_name)
          self.cluster_router = cluster_router_class.new(cluster_config)
          self.shard_repository = ActiveRecord::ShardFor::ShardRepogitory.new(cluster_config, self)
          self.abstract_class = true
        end

        # Returns a generated model class of included model class which has proper
        # connection config for the shard for given key.
        # @param [String] key A value of distkey
        # @return [Class] A generated model class for given distkey value
        def shard_for(key)
          connection_name = cluster_router.fetch_connection_name(key)
          shard_repository.fetch(connection_name)
        end

        # Create new record with given attributes in proper shard for given key.
        # When distkey value is empty, raises ActiveRecord::ShardFor::MissingDistkeyAttribute
        # error.
        # @param [Hash] attributes
        # @return [ActiveRecord::Base] A shard model instance
        # @raise [ActiveRecord::ShardFor::MissingDistkeyAttribute]
        def put!(attributes)
          raise '`distkey` is not defined. Use `def_distkey`.' unless distkey
          key = attributes[distkey]

          raise ActiveRecord::ShardFor::MissingDistkeyAttribute unless key || attributes[distkey.to_s]

          shard_for(key).create!(attributes)
        end

        # Returns nil when not found. Except that, is same as `.get!`.
        # @param [String] key
        # @return [ActiveRecord::Base, nil] A shard model instance
        def get(key)
          shard_for(key).find_by(distkey => key)
        end

        # Distkey is a column. mixed_gauge hashes that value and determine which
        # shard to store.
        # @param [Symbol] column
        def def_distkey(column)
          self.distkey = column.to_sym
        end
      end
    end
  end
end
