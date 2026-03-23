defmodule ItemsApi.Router do
  require Logger

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    route_request(conn)
  end

  defp route_request(conn) do
    case {conn.method, conn.path_info} do
      {"GET", ["health"]} -> health(conn)
      {"GET", ["items"]} -> list_items(conn)
      {"POST", ["items"]} -> create_item(conn)
      {"GET", ["items", id]} -> get_item(conn, id)
      {"DELETE", ["items", id]} -> delete_item(conn, id)
      _ -> not_found(conn)
    end
  end

  defp health(conn) do
    send_json(conn, 200, %{status: "ok"})
  end

  defp list_items(conn) do
    items = ItemsApi.Repo.all(ItemsApi.Item)
    send_json(conn, 200, %{items: items})
  end

  defp create_item(conn) do
    {:ok, body, conn} = Plug.Conn.read_body(conn)

    case Jason.decode(body) do
      {:ok, params} ->
        changeset = ItemsApi.Item.changeset(%ItemsApi.Item{}, params)

        if changeset.valid? do
          case ItemsApi.Repo.insert(changeset) do
            {:ok, item} ->
              send_json(conn, 201, item)

            {:error, _changeset} ->
              send_json(conn, 400, %{error: "Failed to create item"})
          end
        else
          {message, _opts} = changeset.errors[:name] || {"Validation failed", []}
          send_json(conn, 400, %{error: message})
        end

      {:error, _} ->
        send_json(conn, 400, %{error: "Invalid JSON"})
    end
  end

  defp get_item(conn, id) do
    case Integer.parse(id) do
      {int_id, ""} ->
        case ItemsApi.Repo.get(ItemsApi.Item, int_id) do
          nil -> send_json(conn, 404, %{error: "item not found"})
          item -> send_json(conn, 200, item)
        end

      _ ->
        send_json(conn, 404, %{error: "item not found"})
    end
  end

  defp delete_item(conn, id) do
    case Integer.parse(id) do
      {int_id, ""} ->
        case ItemsApi.Repo.get(ItemsApi.Item, int_id) do
          nil ->
            send_json(conn, 404, %{error: "item not found"})

          item ->
            {:ok, _} = ItemsApi.Repo.delete(item)

            conn
            |> Plug.Conn.put_resp_header("content-type", "application/json")
            |> Plug.Conn.send_resp(204, "")
        end

      _ ->
        send_json(conn, 404, %{error: "item not found"})
    end
  end

  defp not_found(conn) do
    send_json(conn, 404, %{error: "not found"})
  end

  defp send_json(conn, status, data) do
    json = Jason.encode!(data)

    conn
    |> Plug.Conn.put_resp_header("content-type", "application/json")
    |> Plug.Conn.send_resp(status, json)
  end
end
