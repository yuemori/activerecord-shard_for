require 'spec_helper'

RSpec.describe ActiveRecord::ShardFor::ClusterConfig do
  let(:cluster_config) { ActiveRecord::ShardFor.config.fetch_cluster_config(cluster_name) }

  describe '#fetch' do
    subject { cluster_config.fetch(key) }

    context 'when key is not range' do
      let(:cluster_name) { :user }

      where(:key, :connection) do
        [
          [0, :test_user_001],
          [1, :test_user_002],
          [2, :test_user_003],
          [3, :test_user_004]
        ]
      end

      with_them do
        it { is_expected.to eq connection }
      end
    end

    context 'when key is range' do
      let(:cluster_name) { :character }

      where(:key, :connection) do
        [
          [0, :test_character_001],
          [100, :test_character_002],
          [200, :test_character_003]
        ]
      end

      with_them do
        it { is_expected.to eq connection }
      end
    end
  end

  describe 'establish_connection' do
    it { expect(Object.const_defined?(:ShardForTestCharacter001)).to be_truthy }
    it { expect(Object.const_defined?(:ShardForTestCharacter002)).to be_truthy }
    it { expect(Object.const_defined?(:ShardForTestCharacter003)).to be_truthy }

    it { expect(Character.using(0).connection).to eq CharacterAnother.using(0).connection }
    it { expect(Character.using(1).connection).to eq CharacterAnother.using(1).connection }
    it { expect(Character.using(2).connection).to eq CharacterAnother.using(2).connection }
    it { expect(Character.using(2).connection).to eq CharacterAnother.using(2).connection }
  end
end
