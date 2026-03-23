ExUnit.start()

# The application is already started by mix test (via mix.exs :mod),
# which starts the Repo and runs migrations. Just set sandbox mode.
Ecto.Adapters.SQL.Sandbox.mode(ItemsApi.Repo, :manual)
