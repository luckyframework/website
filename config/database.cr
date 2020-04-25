AppDatabase.configure do |settings|
  settings.url = "unused"
end

Avram.configure do |settings|
  settings.database_to_migrate = AppDatabase
end
