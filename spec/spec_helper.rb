if ENV['CI']
  require "codeclimate-test-reporter"
  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[CodeClimate::TestReporter::Formatter]
  SimpleCov.start 'test_frameworks'
  CodeClimate::TestReporter.start
end

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

  config.after(:each) do
    User.all_shards.each(&:delete_all)
  end

  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    #     be_bigger_than(2).and_smaller_than(4).description
    #     # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #     # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = false
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.default_formatter = 'doc' if config.files_to_run.one?

  config.warnings = true
  config.profile_examples = 10

  config.order = :random
end
