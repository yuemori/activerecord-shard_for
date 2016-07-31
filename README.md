# ActiveRecord::ShardFor

[![Build Status](https://travis-ci.org/yuemori/activerecord-shard_for.svg?branch=master)](https://travis-ci.org/yuemori/activerecord-shard_for) [![Dependency Status](https://gemnasium.com/badges/github.com/yuemori/activerecord-shard_for.svg)](https://gemnasium.com/github.com/yuemori/activerecord-shard_for) [![Code Climate](https://codeclimate.com/github/yuemori/activerecord-shard_for/badges/gpa.svg)](https://codeclimate.com/github/yuemori/activerecord-shard_for) [![Test Coverage](https://codeclimate.com/github/yuemori/activerecord-shard_for/badges/coverage.svg)](https://codeclimate.com/github/yuemori/activerecord-shard_for/coverage)

This is Sharding Library for ActiveRecord, inspire and import codes from [mixed_gauge](https://github.com/taiki45/mixed_gauge) and [activerecord-sharding](https://github.com/hirocaster/activerecord-sharding) (Thanks!).

## Concept

`activerecord-shard_for` have 3 concepts.

- simple
- small
- pluggable

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-shard_for'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activerecord-shard_for

# Getting Started

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

## Wiki

More imformation and example to see [wiki](https://github.com/yuemori/activerecord-shard_for/wiki)!


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

