defmodule ItemsApi.MigrationTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  describe "auto-migration on startup" do
    test "items table exists after application start" do
      # The application has already started (mix test starts it via mod:),
      # so migrations should have run. Verify the items table exists.
      {:ok, %{rows: tables}} =
        Ecto.Adapters.SQL.query(ItemsApi.Repo, "SELECT name FROM sqlite_master WHERE type='table' AND name='items'")

      assert tables == [["items"]]
    end

    test "items table has expected columns" do
      {:ok, %{rows: columns}} =
        Ecto.Adapters.SQL.query(ItemsApi.Repo, "PRAGMA table_info(items)")

      column_names = Enum.map(columns, fn [_cid, name | _rest] -> name end)
      assert "id" in column_names
      assert "name" in column_names
      assert "description" in column_names
      assert "inserted_at" in column_names
    end

    test "re-running migrations is idempotent" do
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
      # Running migrations again should not crash
      result = Ecto.Migrator.run(ItemsApi.Repo, migrations_path, :up, all: true)
      # Returns empty list when all migrations already applied
      assert result == []
    end
  end
end
