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
        Ecto.Adapters.SQL.query(
          ItemsApi.Repo,
          "SELECT name FROM sqlite_master WHERE type='table' AND name='items'"
        )

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

    test "all migrations are in :up state" do
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
      status = Ecto.Migrator.migrations(ItemsApi.Repo, migrations_path)

      assert length(status) >= 1

      for {state, _version, _name} <- status do
        assert state == :up, "all migrations must be applied"
      end
    end

    test "re-running migrations is idempotent" do
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
      # Running migrations again should not crash
      result = Ecto.Migrator.run(ItemsApi.Repo, migrations_path, :up, all: true)
      # Returns empty list when all migrations already applied
      assert result == []
    end

    test "migration path resolves correctly" do
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")

      assert File.dir?(migrations_path), "migrations directory must exist"
      assert File.ls!(migrations_path) != [], "migrations directory must not be empty"

      migration_files = File.ls!(migrations_path)

      assert Enum.any?(migration_files, &String.contains?(&1, "create_items_table")),
             "items table migration file must exist"
    end

    test "items table is fully functional after auto-migration" do
      # Verify we can actually CRUD against the auto-migrated table
      changeset = ItemsApi.Item.changeset(%ItemsApi.Item{}, %{"name" => "AutoMigTest"})
      {:ok, item} = ItemsApi.Repo.insert(changeset)

      assert item.id != nil
      assert item.name == "AutoMigTest"

      fetched = ItemsApi.Repo.get(ItemsApi.Item, item.id)
      assert fetched.name == "AutoMigTest"

      {:ok, _} = ItemsApi.Repo.delete(item)
      assert ItemsApi.Repo.get(ItemsApi.Item, item.id) == nil
    end
  end
end
