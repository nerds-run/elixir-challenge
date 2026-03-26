defmodule ItemsApi.ItemTest do
  use ExUnit.Case, async: true

  alias ItemsApi.Item

  describe "changeset/2" do
    test "returns invalid changeset when no attrs provided" do
      changeset = Item.changeset(%Item{}, %{})

      refute changeset.valid?
    end

    test "returns valid changeset with name" do
      changeset = Item.changeset(%Item{}, %{"name" => "test"})

      assert changeset.valid?
    end

    test "changeset error for missing name includes correct message" do
      changeset = Item.changeset(%Item{}, %{})

      errors = errors_on(changeset)
      assert errors == %{"name" => ["name is required"]}
    end

    test "returns valid changeset with name and description" do
      changeset = Item.changeset(%Item{}, %{"name" => "Widget", "description" => "A fine widget"})

      assert changeset.valid?
      assert Ecto.Changeset.get_change(changeset, :name) == "Widget"
      assert Ecto.Changeset.get_change(changeset, :description) == "A fine widget"
    end

    test "description defaults to empty string" do
      changeset = Item.changeset(%Item{}, %{"name" => "test"})

      assert changeset.valid?
      # description is not in the changeset changes because the default is on the schema
      assert Ecto.Changeset.get_field(changeset, :description) == ""
    end

    test "rejects empty string name" do
      changeset = Item.changeset(%Item{}, %{"name" => ""})

      refute changeset.valid?
      errors = errors_on(changeset)
      assert Map.has_key?(errors, "name")
    end
  end

  describe "schema" do
    test "has correct fields" do
      fields = Item.__schema__(:fields)

      assert :id in fields
      assert :name in fields
      assert :description in fields
      assert :inserted_at in fields
      refute :updated_at in fields
    end

    test "field types are correct" do
      assert Item.__schema__(:type, :id) == :id
      assert Item.__schema__(:type, :name) == :string
      assert Item.__schema__(:type, :description) == :string
      assert Item.__schema__(:type, :inserted_at) == :utc_datetime
    end
  end

  describe "JSON encoding" do
    test "encodes only specified fields" do
      item = %Item{
        id: 1,
        name: "Test",
        description: "Desc",
        inserted_at: ~U[2026-01-01 00:00:00Z]
      }

      json = Jason.encode!(item)
      decoded = Jason.decode!(json)

      assert Map.has_key?(decoded, "id")
      assert Map.has_key?(decoded, "name")
      assert Map.has_key?(decoded, "description")
      assert Map.has_key?(decoded, "inserted_at")
      assert map_size(decoded) == 4
    end
  end

  # Helper to extract errors from a changeset into a simpler map format
  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, _opts} -> msg end)
    |> Enum.map(fn {key, messages} -> {to_string(key), messages} end)
    |> Map.new()
  end
end
