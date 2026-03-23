import Config

config :items_api,
  ecto_repos: [ItemsApi.Repo]

config :items_api, ItemsApi.Repo,
  database: "./data.db",
  stacktrace: true,
  show_sensitive_data_on_connection_error: true

import_config "#{config_env()}.exs"
