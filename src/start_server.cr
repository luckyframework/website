require "./app"

Habitat.raise_if_missing_settings!

app_server = AppServer.new

Process.on_terminate do
  app_server.close
end

app_server.listen
