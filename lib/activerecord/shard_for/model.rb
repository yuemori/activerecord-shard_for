require 'active_support/concern'

module ActiveRecord
  module ShardFor
    module Model
      extend ActiveSupport::Concern

      included do
        class_attribute :connection_router, instance_writer: false
        class_attribute :shard_repository, instance_writer: false
        class_attribute :replication_mapping, instance_writer: false
        class_attribute :distkey, instance_writer: false
        class_attribute :service, instance_writer: false

        include ActiveRecord::ShardFor::Patch
      end

      module ClassMethods
        # The cluster config must be defined before `use_cluster`
        # @param [Symbol] name A cluster name which is set by ActiveRecord::ShardFor.configure
        def use_cluster(name, router_name, thread_pool_size_base: 3)
          cluster_config = ActiveRecord::ShardFor.config.fetch_cluster_config(name)
          connection_router_class = ActiveRecord::ShardFor.config.fetch_connection_router(router_name)
          self.connection_router = connection_router_class.new(cluster_config)
          self.shard_repository = ActiveRecord::ShardFor::ShardRepository.new(cluster_config, self)
          thread_size = (shard_repository.all.size * thread_pool_size_base)
          self.service = Expeditor::Service.new(
            executor: Concurrent::ThreadPoolExecutor.new(
              min_threads: thread_size,
              max_threads: thread_size,
              max_queue: shard_repository.all.size,
              fallback_policy: :abort
            )
          )
          self.abstract_class = true
        end

        # Returns a generated model class of included model which specific connection.
        # @param [Object] shard_key key of a shard connection
        # @yield [Class] generated model class which key of shard connection
        # @return [Class] generated model class which key of shard connection
        def using(shard_key)
          model = shard_repository.fetch_by_key(shard_key)
          yield model if block_given?
          model
        end

        # Returns a generated model class of included model class which has proper
        # connection config for the shard for given key.
        # @param [String] key A value of distkey
        # @return [Class] A generated model class for given distkey value
        def shard_for(key)
          connection_name = connection_router.fetch_connection_name(key)
          shard_repository.fetch(connection_name)
        end

        # Evaluate block in all shard instances.
        def shard_eval(&block)
          all_shards.each do |shard|
            shard.class_eval(&block)
          end
        end

        # Create new record with given attributes in proper shard for given key.
        # When distkey value is empty, raises ActiveRecord::ShardFor::MissingDistkeyAttribute
        # error.
        # @param [Hash] attributes
        # @return [ActiveRecord::Base] A shard model instance
        # @raise [ActiveRecord::ShardFor::MissingDistkeyAttribute]
        def put!(attributes)
          raise '`distkey` is not defined. Use `def_distkey`.' unless distkey

          @before_put_callback.call(attributes) if defined?(@before_put_callback) && @before_put_callback

          key = fetch_distkey_from_attributes(attributes)

          raise ActiveRecord::ShardFor::MissingDistkeyAttribute unless key

          shard_for(key).create!(attributes)
        end

        # Register hook to assign auto-generated distkey or something.
        # Sometimes you want to generates distkey value before validation. Since
        # activerecord-shard_for generates sub class of your models, AR's callback is not
        # useless for this usecase, so activerecord-shard_for offers its own callback method.
        # @example
        #   class User
        #     include ActiveRecord::ShardFor::Model
        #     use_cluster :user
        #     def_distkey :name
        #     before_put do |attributes|
        #       attributes[:name] = generate_name unless attributes[:name]
        #     end
        #   end
        def before_put(&block)
          @before_put_callback = block
        end

        # Returns nil when not found. Except that, is same as `.get!`.
        # @param [String] key
        # @return [ActiveRecord::Base, nil] A shard model instance
        def get(key)
          shard_for(key).find_by(distkey => key)
        end

        # `.get!` raises ActiveRecord::ShardFor::RecordNotFound which is child class of
        # `ActiveRecord::RecordNotFound` so you can rescue that exception as same
        # as AR's RecordNotFound.
        # @param [String] key
        # @return [ActiveRecord::Base] A shard model instance
        # @raise [ActiveRecord::ShardFor::RecordNotFound]
        def get!(key)
          model = get(key)
          return model if model

          raise ActiveRecord::ShardFor::RecordNotFound
        end

        # Distkey is a column. activerecord-shard_for gave to connection_router that value
        # and connection_router determine which shard to store.
        # @param [Symbol] column
        def def_distkey(column)
          self.distkey = column.to_sym
        end

        # Returns all generated shard model class. Useful to query to all shards.
        # @return [Array<Class>] An array of shard models
        # @example
        #   User.all_shards.flat_map {|m| m.find_by(name: 'alice') }.compact
        def all_shards
          shard_repository.all
        end

        # @return [ActiveRecord::ShardFor::AllShardsInParallel]
        # @example
        #   User.all_shards_in_parallel.map {|m| m.where.find_by(name: 'Alice') }.compact
        def all_shards_in_parallel
          AllShardsInParallel.new(all_shards, service: service)
        end
        alias_method :parallel, :all_shards_in_parallel

        # @param [Hash{Symbol => Symbol}] mapping A pairs of role name and
        #   AR model class name.
        def replicates_with(mapping)
          self.replication_mapping = ActiveRecord::ShardFor::ReplicationMapping.new(mapping)
        end

        # See example definitions in `spec/models.rb`.
        # @param [Symbol] A role name of target cluster.
        # @return [Class, Object] if block given then yielded result else
        #   target shard model.
        # @example
        #   UserReadonly.all_shards.each do |m|
        #     target_ids = m.where(age: 1).pluck(:id)
        #     m.switch(:master) do |master|
        #       master.where(id: target_ids).delete_all
        #     end
        #   end
        def switch(role_name, &block)
          replication_mapping.switch(self, role_name, &block)
        end

        private

        # @param [Hash] attributes
        # @return [Object or nil] distkey
        def fetch_distkey_from_attributes(attributes)
          key = attributes[distkey] || attributes[distkey.to_s]
          return key if key

          instance = all_shards.first.new(attributes)
          return unless instance.respond_to?(distkey)

          instance.send(distkey)
        end
      end
    end
  end
end
