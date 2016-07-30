require 'zlib'

module ActiveRecord
  module ShardFor
    class HashModuloRouter < ClusterRouter
      # @param [String] key sharding key
      def route(key)
        hash(key) % cluster_config.connections.count
      end

      private

      def hash(v)
        Zlib.crc32(v.to_s)
      end
    end
  end
end
