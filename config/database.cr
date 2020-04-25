database_name = "website_v2_#{Lucky::Env.name}"

AppDatabase.configure do |settings|
  settings.url = ENV["DATABASE_URL"]? || Avram::PostgresURL.build(
    database: database_name,
    hostname: ENV["DB_HOST"]? || "localhost",
    username: ENV["DB_USERNAME"]? || "postgres",
    password: ENV["DB_PASSWORD"]? || "postgres"
  )
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase

  # this is moved from your old `Avram::Repo.configure` block.
  settings.lazy_load_enabled = Lucky::Env.production?
end
