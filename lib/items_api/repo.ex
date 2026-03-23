defmodule ItemsApi.Repo do
  use Ecto.Repo,
    otp_app: :items_api,
    adapter: Ecto.Adapters.SQLite3

  def init(_type, config) do
    config = Keyword.put(config, :database, "./data.db")
    {:ok, config}
  end
end
