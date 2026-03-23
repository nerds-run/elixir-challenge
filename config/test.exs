import Config

config :items_api, ItemsApi.Repo,
  database: ":memory:",
  pool: Ecto.Adapters.SQL.Sandbox
