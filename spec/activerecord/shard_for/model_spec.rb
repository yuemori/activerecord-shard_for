require 'spec_helper'

RSpec.describe ActiveRecord::ShardFor::Model do
  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        'User'
      end

      def self.generate_name
        'xxx'
      end

      include MixedGauge::Model
      use_cluster :user
    end
  end
end
