require 'zlib'

module ActiveRecord
  module ShardFor
    class HashModuloRouter < ConnectionRouter
      # @param [String] key sharding key
      def route(key)
        hash(key) % connection_count
      end

      private

      def hash(v)
        Zlib.crc32(v.to_s)
      end
    end
  end
end
