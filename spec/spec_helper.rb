# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'activerecord/shard_for'
require 'rspec-parameterized'
require File.expand_path('../models', __FILE__)

RSpec.configure do |config|
  config.before(:suite) do
    ActiveRecord::Tasks::DatabaseTasks.db_dir = File.expand_path('..', __FILE__)
    ActiveRecord::Tasks::DatabaseTasks.root = File.expand_path('../..', __FILE__)
    ActiveRecord::Tasks::DatabaseTasks.env = 'test'
    args = { cluster_name: 'user' }
    back, $stdout, back_e, $stderr = $stdout, StringIO.new, $stderr, StringIO.new
    ActiveRecord::ShardFor::DatabaseTasks.drop_all_databases(args)
    ActiveRecord::ShardFor::DatabaseTasks.create_all_databases(args)
    ActiveRecord::ShardFor::DatabaseTasks.load_schema_all_databases(args)
    $stdout, $stderr = back, back_e
  end

  config.after(:suite) do
    back, $stdout, back_e, $stderr = $stdout, StringIO.new, $stderr, StringIO.new
    ActiveRecord::ShardFor::DatabaseTasks.drop_all_databases(cluster_name: 'user')
    $stdout, $stderr = back, back_e
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.default_formatter = 'doc' if config.files_to_run.one?

  config.warnings = true
  config.profile_examples = 10

  config.order = :random
end
