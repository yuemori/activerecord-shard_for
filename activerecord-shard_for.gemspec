# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'activerecord/shard_for/version'

Gem::Specification.new do |spec|
  spec.name          = 'activerecord-shard_for'
  spec.version       = ActiveRecord::ShardFor::VERSION
  spec.authors       = ['yuemori']
  spec.email         = ['yuemori@aiming-inc.com']

  spec.summary       = 'Database sharding library for ActiveRecord'
  spec.description   = 'Database sharding library for ActiveRecord'
  spec.homepage      = 'https://github.com/yuemori/activerecord-shard_for'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '>= 4.1.0'
  spec.add_dependency 'activesupport', '>= 4.1.0'
  spec.add_dependency 'expeditor', '>= 0.1.0'
  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-doc'
  spec.add_development_dependency 'pry-stack_explorer'
  spec.add_development_dependency 'pry-inline'
  spec.add_development_dependency 'pry-rescue'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'appraisal'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'rspec-parameterized'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
