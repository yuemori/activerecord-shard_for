# ActiveRecord::ShardFor

[![Build Status](https://travis-ci.org/yuemori/activerecord-shard_for.svg?branch=master)](https://travis-ci.org/yuemori/activerecord-shard_for)

This is Sharding Library for ActiveRecord, inspire and import codes from [mixed_gauge](https://github.com/taiki45/mixed_gauge) and [activerecord-sharding](https://github.com/hirocaster/activerecord-sharding) (Thanks!).

## Concept

`activerecord-shard_for` have 3 concepts.

- simple
- small
- pluggable

### Simple

This idea principal take over from `mixed_gauge`, and `activerecord-sharding`. `activerecord-shard_for` needs minimum and simply of settings.

### Small

- Small Dependency: To facilitate version up (important!).
- Small code: Easy to read code when cause trouble.

### pluggable

Default sharding rule is [modulo with hashed key](https://github.com/yuemori/activerecord-shard_for/blob/master/lib/activerecord/shard_for/hash_modulo_router.rb). But, `activerecord-shard_for` adopt pluggable structer. This rule can be easy to change!

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-shard_for'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-shard_for

## Usage

Add additional database connection config to database.yml.

```yaml
# database.yml
production_user_001:
  adapter: mysql2
  username: user_writable
  host: db-user-001
production_user_002:
  adapter: mysql2
  username: user_writable
  host: db-user-002
production_user_003:
  adapter: mysql2
  username: user_writable
  host: db-user-003
production_user_004:
  adapter: mysql2
  username: user_writable
  host: db-user-004
```

Define cluster in initializers (e.g `initializers/active_record_shard_for.rb`)

```ruby
ActiveRecord::ShardFor.configure do |config|
  config.define_cluster(:user) do |cluster|
    # unique identifier, connection name
    cluster.register(0, :production_user_001)
    cluster.register(1, :production_user_002)
    cluster.register(2, :production_user_003)
    cluster.register(3, :production_user_004)
  end
end
```

Include `ActiveRecord::ShardFor::Model` to your model class, specify cluster name and router name for the model, specify distkey which determines node to store.

```ruby
class User < ActiveRecord::Base
  include ActiveRecord::ShardFor::Model
  use_cluster :user, :hash_modulo # hash_modulo is presented by this library.
  def_distkey :email
end
```

Use `.get` to retrive single record which is connected to proper database node. Use .put! to create new record to proper database node.

`.all_shards` returns each model class which is connected to proper database node. You can query with these models and aggregate result.

```ruby
User.put!(email: 'alice@example.com', name: 'alice')

alice = User.get('alice@example.com')
alice.age = 1
alice.save!

User.all_shards.flat_map {|m| m.find_by(name: 'alice') }.compact
```

When you want to execute queries in all nodes in parallel, use .all_shards_in_parallel. It returns `ActiveRecord::ShardFor::AllShardsInParallel` and it offers some collection actions which runs in parallel. It is aliased to .parallel.

```ruby
User.all_shards_in_parallel.map(&count) #=> 1
User.parallel.flat_map {|m| m.where(age: 1) }.size #=> 1
```


Sometimes you want to generates distkey value before validation. Since activerecord-shard_for generates sub class of your models, AR's callback is usesless for this usecase, so activerecord-shard_for offers its own callback method.

```ruby
class AccessToken < ActiveRecord::Base
  include ActiveRecord::ShardFor::Model
  use_cluster :access_token
  def_distkey :token

  validates :token, presence: true

  def self.generate_token
    SecureRandom.uuid
  end

  before_put do |attributes|
    unless attributes[:token] || attributes['token']
      attributes[:token] = generate_token
    end
  end
end

access_token = AccessToken.put!
access_token.token #=> a generated token
```

## Sharding with Replication

activerecord-shard_for also supports replication.

In case you have 2 shards in cluster and each shard have read replica.

- db-user-101 --replicated--> db-user-102
- db-user-201 --replicated--> db-user-202

Your database connection configuration might be like this:

```yaml
# database.yml
production_user_001:
  adapter: mysql2
  username: user_writable
  host: db-user-101
production_user_002:
  adapter: mysql2
  username: user_writable
  host: db-user-201
production_user_readonly_001:
  adapter: mysql2
  username: user_readonly
  host: db-user-102
production_user_readonly_002:
  adapter: mysql2
  username: user_writable
  host: db-user-202
```

Your initializer for activerecord-shard_for might be like this:

```ruby
ActiveRecord::ShardFor.configure do |config|
  config.define_cluster(:user) do |cluster|
    cluster.register(0, :production_user_001)
    cluster.register(1, :production_user_002)
  end

  config.define_cluster(:user_readonly) do |cluster|
    # give same key of master
    cluster.register(0, :production_user_readonly_001)
    cluster.register(1, :production_user_readonly_002)
  end
end
```

You can split read/write by defining AR model class for each connection:

```ruby
class User < ActiveRecord::Base
  include ActiveRecord::ShardFor::Model
  use_cluster :user
  def_distkey :email
end

class UserReadonly < ActiveRecord::Base
  self.table_name = 'users'

  include ActiveRecord::ShardFor::Model
  use_cluster :user_readonly
  def_distkey :email
end

User.put!(name: 'Alice', email: 'alice@example.com')
UserReadonly.get('alice@example.com')
```

If you want to switch specific shard to another shard in another cluster, define mapping between each model:

```ruby
class User < ActiveRecord::Base
  include ActiveRecord::ShardFor::Model
  use_cluster :user, :hash_modulo
  def_distkey :email

  replicates_with slave: :UserReadonly
end

class UserReadonly < ActiveRecord::Base
  self.table_name = 'users'

  include ActiveRecord::ShardFor::Model
  use_cluster :user_readonly, :hash_modulo
  def_distkey :email

  replicates_with master: :User
end
```

You can switch to another model which have connection to the shard by calling .switch:

```ruby
UserReadonly.all_shards do |readonly|
  target_ids = readonly.where(age: 0).pluck(:id)
  readonly.switch(:master) do |writable|
    writable.where(id: target_ids).delete_all
  end
end
```

## Plugin of cluster router

If you need to advanced cluster routing, implement router class and register this.

Reference a interface to [HashModuloRouter](https://github.com/yuemori/activerecord-shard_for/blob/master/lib/activerecord/shard_for/hash_modulo_router.rb) and [ConnectionRouter](https://github.com/yuemori/activerecord-shard_for/blob/master/lib/activerecord/shard_for/connection_router.rb).

Example, simple modulo router:

```ruby
class SimpleModuloRouter < ActiveRecord::ShardFor::ConnectionRouter
  def route(key)
    key.to_i % connection_count
  end
end
```

Your initializer for activerecord-shard_for might be like this:

```ruby
ActiveRecord::ShardFor.configure do |config|
  config.register_cluster_router(:modulo, SimpleModuloRouter)
end
```

And specify router in your AR model.

```ruby
class User < ActiveRecord::Base
  include ActiveRecord::ShardFor::Model
  use_cluster :user, :modulo
  def_distkey :id

  def self.generate_unique_id
    # Implement to generate unique id
  end

  before_put do |attributes|
    attributes[:id] = generate_unique_id unless attributes[:id]
  end
end
```

## Contributing with ActiveRecord::ShardFor

Contributors are welcome! This is what you need to setup your Octopus development environment:

```sh
$ git clone https://github.com/yuemori/activerecord-shard_for
$ cd activerecord-shard_for
$ bundle install
$ bundle exec rake appraisal:install
$ bundle exec rake spec
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

