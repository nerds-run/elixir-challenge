defmodule ItemsApi.ApplicationTest do
  use ExUnit.Case, async: false

  describe "application supervision tree" do
    test "supervisor is running" do
      assert Process.whereis(ItemsApi.Supervisor) != nil
    end

    test "Repo is running under supervisor" do
      assert Process.whereis(ItemsApi.Repo) != nil
    end

    test "supervisor has expected children running" do
      children = Supervisor.count_children(ItemsApi.Supervisor)
      # Supervisor should have at least 2 active children (Repo + Bandit)
      assert children[:active] >= 2
    end
  end
end
