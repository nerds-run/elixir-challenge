import Config

config :items_api, ItemsApi.Repo,
  database: "./test_data.db",
  pool: Ecto.Adapters.SQL.Sandbox
