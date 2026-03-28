defmodule ItemsApi.GetItemTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  defp call(conn) do
    ItemsApi.Router.call(conn, ItemsApi.Router.init([]))
  end

  defp json_response(conn) do
    Jason.decode!(conn.resp_body)
  end

  defp create_item(attrs \\ %{}) do
    default = %{"name" => "Test Item", "description" => "A test item"}
    changeset = ItemsApi.Item.changeset(%ItemsApi.Item{}, Map.merge(default, attrs))
    {:ok, item} = ItemsApi.Repo.insert(changeset)
    item
  end

  describe "GET /items/:id" do
    test "returns HTTP 200 for existing item" do
      item = create_item()
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      assert conn.status == 200
    end

    test "returns item with correct JSON body" do
      item = create_item(%{"name" => "Widget", "description" => "A fine widget"})
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      resp = json_response(conn)
      assert resp["id"] == item.id
      assert resp["name"] == "Widget"
      assert resp["description"] == "A fine widget"
      assert resp["inserted_at"] != nil
    end

    test "response body contains exactly id, name, description, inserted_at" do
      item = create_item()
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      resp = json_response(conn)
      assert Map.keys(resp) |> Enum.sort() == ["description", "id", "inserted_at", "name"]
    end

    test "id is an integer" do
      item = create_item()
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      assert is_integer(json_response(conn)["id"])
    end

    test "inserted_at is a valid ISO 8601 datetime string" do
      item = create_item()
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      inserted_at = json_response(conn)["inserted_at"]
      assert is_binary(inserted_at)
      assert {:ok, _dt, _offset} = DateTime.from_iso8601(inserted_at)
    end

    test "returns item with default empty description" do
      changeset = ItemsApi.Item.changeset(%ItemsApi.Item{}, %{"name" => "No Desc"})
      {:ok, item} = ItemsApi.Repo.insert(changeset)
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      assert json_response(conn)["description"] == ""
    end

    test "sets Content-Type to application/json" do
      item = create_item()
      conn = Plug.Test.conn(:get, "/items/#{item.id}") |> call()

      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end

    test "returns HTTP 404 for non-existent id" do
      conn = Plug.Test.conn(:get, "/items/9999") |> call()

      assert conn.status == 404
    end

    test "returns exact error message for non-existent id" do
      conn = Plug.Test.conn(:get, "/items/9999") |> call()

      assert json_response(conn) == %{"error" => "item not found"}
    end

    test "returns 404 with error for non-integer id" do
      conn = Plug.Test.conn(:get, "/items/abc") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end

    test "returns 404 for float-like id" do
      conn = Plug.Test.conn(:get, "/items/1.5") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end

    test "returns 404 for negative id" do
      conn = Plug.Test.conn(:get, "/items/-1") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end

    test "returns 404 for zero id" do
      conn = Plug.Test.conn(:get, "/items/0") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end

    test "404 response sets Content-Type to application/json" do
      conn = Plug.Test.conn(:get, "/items/9999") |> call()

      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end

    test "returns correct item when multiple exist" do
      _first = create_item(%{"name" => "First"})
      second = create_item(%{"name" => "Second"})
      _third = create_item(%{"name" => "Third"})

      conn = Plug.Test.conn(:get, "/items/#{second.id}") |> call()

      assert conn.status == 200
      assert json_response(conn)["name"] == "Second"
    end

    test "unsupported methods on /items/:id return 404" do
      item = create_item()

      for method <- [:put, :patch, :post] do
        conn = Plug.Test.conn(method, "/items/#{item.id}") |> call()
        assert conn.status == 404, "Expected 404 for #{method |> to_string() |> String.upcase()} /items/#{item.id}"
      end
    end
  end
end
