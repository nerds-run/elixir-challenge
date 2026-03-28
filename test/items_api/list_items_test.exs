defmodule ItemsApi.ListItemsTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  defp call(conn) do
    ItemsApi.Router.call(conn, ItemsApi.Router.init([]))
  end

  defp insert_item!(attrs) do
    %ItemsApi.Item{}
    |> ItemsApi.Item.changeset(attrs)
    |> ItemsApi.Repo.insert!()
  end

  describe "GET /items" do
    test "returns HTTP 200 with empty array when no items exist" do
      conn = Plug.Test.conn(:get, "/items") |> call()

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{"items" => []}
    end

    test "sets Content-Type to application/json" do
      conn = Plug.Test.conn(:get, "/items") |> call()

      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end

    test "returns items array with all required fields after insert" do
      item = insert_item!(%{"name" => "test", "description" => "a test item"})

      conn = Plug.Test.conn(:get, "/items") |> call()

      assert conn.status == 200
      %{"items" => [returned_item]} = Jason.decode!(conn.resp_body)

      assert returned_item["id"] == item.id
      assert returned_item["name"] == "test"
      assert returned_item["description"] == "a test item"
      assert is_binary(returned_item["inserted_at"])
    end

    test "each item includes exactly id, name, description, and inserted_at" do
      insert_item!(%{"name" => "widget"})

      conn = Plug.Test.conn(:get, "/items") |> call()

      %{"items" => [returned_item]} = Jason.decode!(conn.resp_body)
      assert Map.keys(returned_item) |> Enum.sort() == ["description", "id", "inserted_at", "name"]
    end

    test "description defaults to empty string when not provided" do
      insert_item!(%{"name" => "no-desc"})

      conn = Plug.Test.conn(:get, "/items") |> call()

      %{"items" => [returned_item]} = Jason.decode!(conn.resp_body)
      assert returned_item["description"] == ""
    end

    test "response format matches expected structure" do
      item = insert_item!(%{"name" => "test", "description" => ""})

      conn = Plug.Test.conn(:get, "/items") |> call()

      body = Jason.decode!(conn.resp_body)
      assert is_map(body)
      assert Map.has_key?(body, "items")
      assert is_list(body["items"])

      [returned] = body["items"]
      assert returned["id"] == item.id
      assert returned["name"] == "test"
      assert returned["description"] == ""
      assert is_binary(returned["inserted_at"])
    end

    test "returns multiple items" do
      insert_item!(%{"name" => "first", "description" => "first item"})
      insert_item!(%{"name" => "second", "description" => "second item"})
      insert_item!(%{"name" => "third", "description" => ""})

      conn = Plug.Test.conn(:get, "/items") |> call()

      assert conn.status == 200
      %{"items" => items} = Jason.decode!(conn.resp_body)
      assert length(items) == 3

      names = Enum.map(items, & &1["name"]) |> Enum.sort()
      assert names == ["first", "second", "third"]
    end

    test "id is an integer" do
      insert_item!(%{"name" => "typed"})

      conn = Plug.Test.conn(:get, "/items") |> call()

      %{"items" => [item]} = Jason.decode!(conn.resp_body)
      assert is_integer(item["id"])
    end

    test "inserted_at is a valid ISO 8601 datetime string" do
      insert_item!(%{"name" => "timestamped"})

      conn = Plug.Test.conn(:get, "/items") |> call()

      %{"items" => [item]} = Jason.decode!(conn.resp_body)
      assert {:ok, _dt, _offset} = DateTime.from_iso8601(item["inserted_at"])
    end

    test "POST /items returns 404 for unsupported method on collection" do
      conn = Plug.Test.conn(:put, "/items") |> call()

      assert conn.status == 404
    end
  end
end
