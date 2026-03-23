defmodule ItemsApi.Application do
  use Application

  @impl true
  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "4000")

    children = [
      {ItemsApi.Repo, []},
      {Bandit, plug: ItemsApi.Router, port: port}
    ]

    opts = [strategy: :one_for_one, name: ItemsApi.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    run_migrations()

    {:ok, pid}
  end

  defp run_migrations do
    migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
    Ecto.Migrator.run(ItemsApi.Repo, migrations_path, :up, all: true)
  end
end
