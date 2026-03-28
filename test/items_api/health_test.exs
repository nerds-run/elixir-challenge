defmodule ItemsApi.HealthTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  defp call(conn) do
    ItemsApi.Router.call(conn, ItemsApi.Router.init([]))
  end

  describe "GET /health" do
    test "returns HTTP 200" do
      conn = Plug.Test.conn(:get, "/health") |> call()

      assert conn.status == 200
    end

    test "returns {\"status\": \"ok\"} JSON body" do
      conn = Plug.Test.conn(:get, "/health") |> call()

      assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
    end

    test "sets content-type to application/json" do
      conn = Plug.Test.conn(:get, "/health") |> call()

      assert Plug.Conn.get_resp_header(conn, "content-type") == ["application/json"]
    end

    test "requires no request body" do
      conn = Plug.Test.conn(:get, "/health") |> call()

      assert conn.status == 200
      assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
    end

    test "POST /health returns 404" do
      conn = Plug.Test.conn(:post, "/health") |> call()

      assert conn.status == 404
    end

    test "PUT /health returns 404" do
      conn = Plug.Test.conn(:put, "/health") |> call()

      assert conn.status == 404
    end

    test "DELETE /health returns 404" do
      conn = Plug.Test.conn(:delete, "/health") |> call()

      assert conn.status == 404
    end

    test "is idempotent across multiple calls" do
      for _ <- 1..3 do
        conn = Plug.Test.conn(:get, "/health") |> call()

        assert conn.status == 200
        assert Jason.decode!(conn.resp_body) == %{"status" => "ok"}
      end
    end
  end
end
