namespace :activerecord do
  namespace :shard_for do
    desc 'Show all defined clusters and their detail'
    task info: %i(environment) do
      ActiveRecord::ShardFor::DatabaseTasks.info
    end

    desc 'Setup all databases in all clusters'
    task setup: %i(create_all load_schema_all) do
    end

    desc 'Create all databases in all clusters'
    task :create_all => :environment do
      ActiveRecord::ShardFor::DatabaseTasks.invoke_task_for_all_clusters('create')
    end

    desc 'Drop all databases in all clusters'
    task :drop_all => :environment do
      ActiveRecord::ShardFor::DatabaseTasks.invoke_task_for_all_clusters('drop')
    end

    desc 'Load schema to all databases in all clusters'
    task :load_schema_all => :environment do
      ActiveRecord::ShardFor::DatabaseTasks.invoke_task_for_all_clusters('load_schema')
    end

    desc 'Create all databases in specific cluster'
    task :create, %i(cluster_name) => %i(environment) do |_, args|
      ActiveRecord::ShardFor::DatabaseTasks.create_all_databases(args)
    end

    desc 'Drop all databases in specific cluster'
    task :drop, %i(cluster_name) => %i(environment) do |_, args|
      ActiveRecord::ShardFor::DatabaseTasks.drop_all_databases(args)
    end

    desc 'Load schema to all databases in specific cluster'
    task :load_schema, %i(cluster_name) => %i(environment) do |_, args|
      ActiveRecord::ShardFor::DatabaseTasks.load_schema_all_databases(args)
    end
  end
end
