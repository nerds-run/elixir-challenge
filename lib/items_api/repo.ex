defmodule ItemsApi.Repo do
  use Ecto.Repo,
    otp_app: :items_api,
    adapter: Ecto.Adapters.SQLite3

  def init(_type, config) do
    database =
      System.get_env("DATABASE_PATH") ||
        Keyword.get(config, :database, "./data.db")

    {:ok, Keyword.put(config, :database, database)}
  end
end
