require_relative './config/environment'

ActiveRecord::Base.connection.transaction do
  # Disable foreign key checks temporarily (for PostgreSQL)
  ActiveRecord::Base.connection.execute("SET session_replication_role = 'replica';")

  # Define tables to **keep** (not truncated)
  KEEP_TABLES = %w[
    users
    parts
    suppliers
    sub_contractors
    logistic_places
    warehouses
    clients
    companies
    accounts
    schema_migrations
    ar_internal_metadata
  ]

  # Get all table names except those we want to keep
  tables_to_truncate = ActiveRecord::Base.connection.tables - KEEP_TABLES

  # Truncate only selected tables
  tables_to_truncate.each do |table|
    ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table} CASCADE;")
    puts "Truncated #{table}"
  end

  # Re-enable foreign key checks
  ActiveRecord::Base.connection.execute("SET session_replication_role = 'origin';")
end

puts "Database cleanup complete. Business-related data has been removed while preserving essential records."