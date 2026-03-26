defmodule ItemsApi.RepoTest do
  use ExUnit.Case, async: false

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ItemsApi.Repo)
    :ok
  end

  describe "Repo" do
    test "is running and accepting queries" do
      assert {:ok, %{rows: [[1]]}} = Ecto.Adapters.SQL.query(ItemsApi.Repo, "SELECT 1")
    end

    test "uses SQLite3 adapter" do
      assert ItemsApi.Repo.__adapter__() == Ecto.Adapters.SQLite3
    end

    test "has otp_app set to :items_api" do
      config = ItemsApi.Repo.config()
      assert config[:otp_app] == :items_api
    end
  end
end
