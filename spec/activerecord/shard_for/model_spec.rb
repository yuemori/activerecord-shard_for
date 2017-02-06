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

      include ActiveRecord::ShardFor::Model
      use_cluster :user, :hash_modulo
      def_distkey :email

      before_put do |attrs|
        attrs[:name] = generate_name unless attrs[:name]
      end
    end
  end

  let!(:another_model) do
    Class.new(ActiveRecord::Base) do
      def self.name
        'User'
      end

      include ActiveRecord::ShardFor::Model
      use_cluster :character, :distkey
      def_distkey :shard_no

      def shard_no
        1
      end
    end
  end

  let(:user_attributes) { { name: 'Alice', email: 'alice@example.com' } }

  describe '.put!' do
    it 'creates new record into proper node' do
      record = model.put!(user_attributes)
      expect(record).to be_a(model)
      expect(record.email).to eq('alice@example.com')
      expect(record).to be_respond_to(:save!)
    end

    context 'without distkey attributes' do
      before { user_attributes.delete(:email) }

      it 'raises MissingDistkeyAttribute error' do
        expect { model.put!(user_attributes) }
          .to raise_error(ActiveRecord::ShardFor::MissingDistkeyAttribute)
      end
    end

    context 'distkey be specify instance method' do
      before { another_model.put!(user_attributes) }

      it 'creates new record into shard 1' do
        record = another_model.using(1).find_by(email: user_attributes[:email])
        expect(record).to be_a(another_model)
        expect(record).not_to be_nil
      end
    end
  end

  describe '.before_put' do
    it 'calls registered hook before execute `put`' do
      record = model.put!(email: 'xxx@example.com')
      expect(record.name).to eq('xxx')
    end
  end

  describe '.get' do
    context 'when record exists' do
      before { model.put!(user_attributes) }
      it 'returns AR::B instance from proper node' do
        record = model.get('alice@example.com')
        expect(record).to be_a(model)
        expect(record.email).to eq('alice@example.com')
        expect(record).to be_respond_to(:save!)
      end
    end

    context 'when record not exists' do
      it 'returns nil' do
        expect(model.get('not_exist@example.com')).to be_nil
      end
    end
  end

  describe '.get!' do
    context 'when record exists' do
      before { model.put!(user_attributes) }

      it 'returns proper record' do
        record = model.get('alice@example.com')
        expect(record.email).to eq('alice@example.com')
      end
    end

    context 'when record not exists' do
      it 'raises ActiveRecord::ShardFor::RecordNotFound' do
        expect { model.get!('not_exist@example.com') }
          .to raise_error(ActiveRecord::ShardFor::RecordNotFound)
      end

      it 'raises sub class of ActiveRecord::RecordNotFound' do
        expect { model.get!('not_exist@example.com') }
          .to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe '.shard_for' do
    before { model.put!(user_attributes) }

    it 'enables to use finder method' do
      record = model.shard_for('alice@example.com').find_by(name: 'Alice')
      expect(record).not_to be_nil
      expect(record.name).to eq('Alice')
    end
  end

  describe '.all_shards' do
    before { model.put!(user_attributes) }

    it 'returns all AR model classes and can search by finder methods' do
      records = model.all_shards.flat_map { |m| m.find_by(name: 'Alice') }.compact
      expect(records.size).to eq(1)
    end
  end

  describe '.switch' do
    it 'retuns result' do
      result = User.shard_for('x').switch(:slave) { 1 }
      expect(result).to eq(1)
    end
  end

  describe '.all_shards_in_parallel' do
    it 'returns a ActiveRecord::ShardFor::AllShardsInParallel' do
      expect(User.all_shards_in_parallel).to be_a(ActiveRecord::ShardFor::AllShardsInParallel)
    end
  end

  describe '.using' do
    context 'when block given' do
      before { model.using(0) { |model| model.create(user_attributes) } }

      it 'enables to use finder method' do
        record = model.using(0).find_by(name: 'Alice')
        expect(record).not_to be_nil
        expect(record.name).to eq('Alice')
      end
    end

    context 'when block given' do
      before { model.using(0).create(user_attributes) }

      it 'enables to use finder method' do
        record = model.using(0).find_by(name: 'Alice')
        expect(record).not_to be_nil
        expect(record.name).to eq('Alice')
      end
    end
  end

  describe 'establish_connection to same shard' do
    before do
      ActiveRecord::Base.clear_all_connections!
    end

    it 'uses same connection' do
      aggregate_failures do
        (0..3).to_a.each do |n|
          publisher_class = ShardForTestCharacter001 # eq Account.using(n).name.demodulize

          connections = [
            Account.using(n).connection,
            Character.using(n).connection,
            Item.using(n).connection,
            publisher_class.connection
          ]
          expect(connections).to all be_present

          connection_pools = [
            Account.using(n).connection_pool,
            Character.using(n).connection_pool,
            Item.using(n).connection_pool,
            publisher_class.connection_pool
          ]

          expect(connections.uniq.length).to eq 1
          expect(connection_pools.uniq.length).to eq 1
          expect(publisher_class.connection).not_to eq Product.using(n).connection
        end
      end
    end

    it 'effects transaction' do
      aggregate_failures do
        (0..3).to_a.each do |n|
          Account.using(n).transaction do
            Item.using(n).create!(name: 'test item')
            raise ActiveRecord::Rollback
          end
          expect(Item.using(n).count).to be_zero
        end
      end
    end
  end
end
