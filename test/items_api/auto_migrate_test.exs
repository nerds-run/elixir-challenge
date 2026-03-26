defmodule ItemsApi.AutoMigrateTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  describe "auto-migration on startup" do
    test "items table exists after application startup" do
      # The application has already started (via mix test which starts the app).
      # Auto-migration should have run, creating the items table.
      result =
        Ecto.Adapters.SQL.query!(
          ItemsApi.Repo,
          "SELECT name FROM sqlite_master WHERE type='table' AND name='items'"
        )

      assert result.rows == [["items"]]
    end

    test "all migrations are in :up state" do
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
      status = Ecto.Migrator.migrations(ItemsApi.Repo, migrations_path)

      assert length(status) >= 1

      for {state, _version, _name} <- status do
        assert state == :up, "all migrations must be applied"
      end
    end

    test "re-running migrations is idempotent (no error)" do
      # Calling run_migrations again should not raise — already-applied migrations are skipped.
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")

      # This should return an empty list (nothing to migrate) and not crash.
      result = Ecto.Migrator.run(ItemsApi.Repo, migrations_path, :up, all: true)

      assert result == [], "no new migrations should be applied"
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
