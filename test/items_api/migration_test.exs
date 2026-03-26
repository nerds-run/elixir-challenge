defmodule ItemsApi.MigrationTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  describe "items table migration" do
    test "items table exists" do
      result =
        Ecto.Adapters.SQL.query!(
          ItemsApi.Repo,
          "SELECT name FROM sqlite_master WHERE type='table' AND name='items'"
        )

      assert length(result.rows) == 1
      assert hd(result.rows) == ["items"]
    end

    test "items table has correct columns" do
      result = Ecto.Adapters.SQL.query!(ItemsApi.Repo, "PRAGMA table_info(items)")

      columns =
        Enum.map(result.rows, fn [_cid, name, type, notnull, dflt_value, _pk] ->
          %{name: name, type: type, notnull: notnull, default: dflt_value}
        end)

      id_col = Enum.find(columns, &(&1.name == "id"))
      assert id_col != nil, "id column must exist"
      assert id_col.type == "INTEGER"

      name_col = Enum.find(columns, &(&1.name == "name"))
      assert name_col != nil, "name column must exist"
      assert name_col.type == "TEXT"
      assert name_col.notnull == 1, "name must be NOT NULL"

      desc_col = Enum.find(columns, &(&1.name == "description"))
      assert desc_col != nil, "description column must exist"
      assert desc_col.type == "TEXT"
      assert desc_col.notnull == 1, "description must be NOT NULL"
      assert desc_col.default == "''", "description must default to empty string"

      inserted_col = Enum.find(columns, &(&1.name == "inserted_at"))
      assert inserted_col != nil, "inserted_at column must exist"
      assert inserted_col.type == "TEXT"
      assert inserted_col.notnull == 1, "inserted_at must be NOT NULL"

      updated_col = Enum.find(columns, &(&1.name == "updated_at"))
      assert updated_col == nil, "updated_at column must NOT exist"
    end

    test "id column is auto-increment primary key" do
      result = Ecto.Adapters.SQL.query!(ItemsApi.Repo, "PRAGMA table_info(items)")

      id_row = Enum.find(result.rows, fn [_cid, name | _rest] -> name == "id" end)
      # In PRAGMA table_info, the last column (pk) is 1 for primary key
      [_cid, _name, _type, _notnull, _dflt, pk] = id_row
      assert pk == 1, "id must be primary key"
    end

    test "migration runs without error (already applied)" do
      # Migrations are already run by the application on startup.
      # Verify the migration status shows it as applied.
      migrations_path = Application.app_dir(:items_api, "priv/repo/migrations")
      status = Ecto.Migrator.migrations(ItemsApi.Repo, migrations_path)

      assert length(status) >= 1

      {state, _version, _name} = hd(status)
      assert state == :up, "migration must be in :up state"
    end
  end
end
