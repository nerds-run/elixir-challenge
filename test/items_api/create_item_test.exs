defmodule ItemsApi.CreateItemTest do
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

  describe "POST /items - Default Description Behavior" do
    test "POST with only name defaults description to empty string" do
      body = Jason.encode!(%{name: "Widget"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      assert resp["name"] == "Widget"
      assert resp["description"] == ""
      assert is_integer(resp["id"])
      assert resp["inserted_at"] != nil
    end

    test "POST with explicit description uses provided value" do
      body = Jason.encode!(%{name: "Gadget", description: "A fine gadget"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      assert resp["name"] == "Gadget"
      assert resp["description"] == "A fine gadget"
    end

    test "POST with empty string description uses empty string" do
      body = Jason.encode!(%{name: "Thingamajig", description: ""})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      assert resp["name"] == "Thingamajig"
      assert resp["description"] == ""
    end

    test "POSTed item with default description persists in database" do
      body = Jason.encode!(%{name: "Persisted Item"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      item_id = resp["id"]

      # Verify the item was persisted with default description
      persisted_item = ItemsApi.Repo.get(ItemsApi.Item, item_id)
      assert persisted_item.name == "Persisted Item"
      assert persisted_item.description == ""
    end

    test "Response has application/json content-type" do
      body = Jason.encode!(%{name: "JSON Test"})
      conn = json_conn(:post, "/items", body) |> call()

      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end

    test "Response includes all required fields" do
      body = Jason.encode!(%{name: "Full Item"})
      conn = json_conn(:post, "/items", body) |> call()

      assert conn.status == 201
      resp = json_response(conn)
      assert Map.has_key?(resp, "id")
      assert Map.has_key?(resp, "name")
      assert Map.has_key?(resp, "description")
      assert Map.has_key?(resp, "inserted_at")
      assert map_size(resp) == 4
    end
  end
end
