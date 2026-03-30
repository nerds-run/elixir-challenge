defmodule ItemsApi.RouterTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  defp call(conn) do
    ItemsApi.Router.call(conn, ItemsApi.Router.init([]))
  end

  defp json_conn(method, path, body \\ nil) do
    conn = Plug.Test.conn(method, path, body)

    if body do
      Plug.Conn.put_req_header(conn, "content-type", "application/json")
    else
      conn
    end
  end

  defp json_response(conn) do
    Jason.decode!(conn.resp_body)
  end

  describe "GET /health" do
    test "returns 200 with status ok" do
      conn = json_conn(:get, "/health") |> call()

      assert conn.status == 200
      assert json_response(conn) == %{"status" => "ok"}
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end
  end

  describe "GET /items" do
    test "returns empty list when no items" do
      conn = json_conn(:get, "/items") |> call()

      assert conn.status == 200
      assert json_response(conn) == %{"items" => []}
    end

    test "returns list of items" do
      {:ok, _item} =
        ItemsApi.Repo.insert(
          ItemsApi.Item.changeset(%ItemsApi.Item{}, %{"name" => "Test Item"})
        )

      conn = json_conn(:get, "/items") |> call()

      assert conn.status == 200
      %{"items" => items} = json_response(conn)
      assert length(items) == 1
      assert hd(items)["name"] == "Test Item"
    end
  end

  describe "POST /items" do
    test "creates item with name and description" do
      body = Jason.encode!(%{name: "Widget", description: "A fine widget"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      assert resp["name"] == "Widget"
      assert resp["description"] == "A fine widget"
      assert is_integer(resp["id"])
      assert resp["inserted_at"] != nil
    end

    test "creates item with default empty description when omitted" do
      body = Jason.encode!(%{name: "Gadget"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      assert resp["name"] == "Gadget"
      assert resp["description"] == ""
    end

    test "returns 400 when name is missing" do
      body = Jason.encode!(%{description: "no name"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 400
      assert json_response(conn) == %{"error" => "name is required"}
    end

    test "returns 400 when name is empty string" do
      body = Jason.encode!(%{name: ""})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 400
      assert json_response(conn) == %{"error" => "name is required"}
    end

    test "returns 400 for invalid JSON" do
      conn = json_conn(:post, "/items", "not json") |> call()

      assert conn.status == 400
      assert json_response(conn)["error"] != nil
    end
  end

  describe "GET /items/:id" do
    test "returns item when found" do
      {:ok, item} =
        ItemsApi.Repo.insert(
          ItemsApi.Item.changeset(%ItemsApi.Item{}, %{"name" => "Lookup"})
        )

      conn = json_conn(:get, "/items/#{item.id}") |> call()

      assert conn.status == 200
      resp = json_response(conn)
      assert resp["id"] == item.id
      assert resp["name"] == "Lookup"
    end

    test "returns 404 when item not found" do
      conn = json_conn(:get, "/items/99999") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end

    test "returns 404 for non-integer id" do
      conn = json_conn(:get, "/items/abc") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end
  end

  describe "DELETE /items/:id" do
    test "deletes item and returns 204" do
      {:ok, item} =
        ItemsApi.Repo.insert(
          ItemsApi.Item.changeset(%ItemsApi.Item{}, %{"name" => "Doomed"})
        )

      conn = json_conn(:delete, "/items/#{item.id}") |> call()

      assert conn.status == 204
      assert conn.resp_body == ""

      # Verify deletion
      assert ItemsApi.Repo.get(ItemsApi.Item, item.id) == nil
    end

    test "returns 404 when item not found" do
      conn = json_conn(:delete, "/items/99999") |> call()

      assert conn.status == 404
      assert json_response(conn) == %{"error" => "item not found"}
    end
  end

  describe "Content-Type" do
    test "all responses have application/json content-type" do
      health = json_conn(:get, "/health") |> call()
      assert Plug.Conn.get_resp_header(health, "content-type") == ["application/json"]

      items = json_conn(:get, "/items") |> call()
      assert Plug.Conn.get_resp_header(items, "content-type") == ["application/json"]

      not_found = json_conn(:get, "/items/99999") |> call()
      assert Plug.Conn.get_resp_header(not_found, "content-type") == ["application/json"]
    end

    test "DELETE responses include content-type header" do
      {:ok, item} =
        ItemsApi.Repo.insert(
          ItemsApi.Item.changeset(%ItemsApi.Item{}, %{"name" => "Test Delete"})
        )

      # Successful delete (204) has content-type
      conn = json_conn(:delete, "/items/#{item.id}") |> call()
      assert conn.status == 204
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]

      # Not found (404) has content-type
      conn = json_conn(:delete, "/items/99999") |> call()
      assert conn.status == 404
      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end
  end

  describe "unknown routes" do
    test "returns 404" do
      conn = json_conn(:get, "/unknown") |> call()

      assert conn.status == 404
      assert json_response(conn)["error"] == "not found"
    end
  end
end
