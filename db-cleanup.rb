# db_truncate.rb

require_relative './config/environment'

ActiveRecord::Base.connection.transaction do
  # Disable foreign key checks temporarily
  ActiveRecord::Base.connection.execute("SET session_replication_role = 'replica';")

  # Get all table names except `users`, `schema_migrations`, and `ar_internal_metadata`
  tables = ActiveRecord::Base.connection.tables - ['schema_migrations', 'ar_internal_metadata']

  # Truncate each table to delete all data
  tables.each do |table|
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
    puts "Truncated #{table}"
  end

  # Re-enable foreign key checks
  ActiveRecord::Base.connection.execute("SET session_replication_role = 'origin';")
end

puts "Database cleanup complete. All tables except the ones you choose have been truncated."
