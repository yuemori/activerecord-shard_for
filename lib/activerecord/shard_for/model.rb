require 'active_support/concern'

module ActiveRecord
  module ShardFor
    module Model
      extend ActiveSupport::Concern

      module ClassMethods
        # The cluster config must be defined before `use_cluster`
        # @param [Symbol] name A cluster name which is set by ActiveRecord::ShardFor.configure
        def use_cluster(name)
          cluster_config = ActiveRecord::ShardFor.config.fetch_cluster_config(name)
          self.abstract_class = true
        end
      end
    end
  end
end
