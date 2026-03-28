defmodule ItemsApi.Application do
  use Application

  @default_port 4000

  @impl true
  def start(_type, _args) do
    port = resolve_port()

    children = [
      {ItemsApi.Repo, []},
      {Bandit, plug: ItemsApi.Router, port: port}
    ]

    opts = [strategy: :one_for_one, name: ItemsApi.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    run_migrations()

    {:ok, pid}
  end

  @doc """
  Resolves the port from the PORT environment variable.

  Returns the integer value of PORT if set and valid,
  otherwise returns the default port (4000).

  Invalid PORT values (non-numeric strings) are ignored
  and the default port is used instead, with a warning logged.
  """
  @spec resolve_port() :: non_neg_integer()
  def resolve_port do
    case System.get_env("PORT") do
      nil ->
        @default_port

      port_string ->
        parse_port(port_string)
    end
  end

  @doc false
  def default_port, do: @default_port

  defp parse_port(port_string) do
    case Integer.parse(port_string) do
      {port, ""} when port > 0 and port <= 65_535 ->
        port

      _ ->
        require Logger
        Logger.warning("Invalid PORT value #{inspect(port_string)}, falling back to #{@default_port}")
        @default_port
    end
  end

  defp run_migrations do
    migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
    Ecto.Migrator.run(ItemsApi.Repo, migrations_path, :up, all: true)
  end
end
