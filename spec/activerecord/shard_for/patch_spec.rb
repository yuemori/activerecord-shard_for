require 'spec_helper'

RSpec.describe ActiveRecord::ShardFor::Patch do
  let!(:model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        'User'
      end

      def self.generate_name
        'xxx'
      end

      include ActiveRecord::ShardFor::Model
      use_cluster :user, :hash_modulo
      def_distkey :email

      enum sex: { male: 0, female: 1 }

      before_put do |attrs|
        attrs[:name] = generate_name unless attrs[:name]
      end

      define_callbacks :sample_callback
      set_callback :sample_callback, :before, :hoge
    end
  end

  describe '.enum' do
    subject { model.defined_enums }

    it { is_expected.not_to be_empty }
  end

  describe 'callbacks' do
    before do
      model.define_callbacks :sample_callback2
    end

    it { expect { model.set_callback :sample_callback2, :before, :email }.not_to raise_error }
  end
end
