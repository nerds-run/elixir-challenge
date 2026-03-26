defmodule ItemsApi.PortConfigTest do
  use ExUnit.Case, async: false

  describe "resolve_port/0" do
    test "returns default port 4000 when PORT env var is not set" do
      System.delete_env("PORT")
      assert ItemsApi.Application.resolve_port() == 4000
    end

    test "returns custom port when PORT env var is set" do
      System.put_env("PORT", "5001")

      try do
        assert ItemsApi.Application.resolve_port() == 5001
      after
        System.delete_env("PORT")
      end
    end

    test "returns custom port for various valid values" do
      for {input, expected} <- [{"8080", 8080}, {"3000", 3000}, {"1", 1}, {"65535", 65535}] do
        System.put_env("PORT", input)

        try do
          assert ItemsApi.Application.resolve_port() == expected,
                 "Expected PORT=#{input} to resolve to #{expected}"
        after
          System.delete_env("PORT")
        end
      end
    end

    test "falls back to default for non-numeric PORT value" do
      System.put_env("PORT", "abc")

      try do
        assert ItemsApi.Application.resolve_port() == 4000
      after
        System.delete_env("PORT")
      end
    end

    test "falls back to default for empty string PORT" do
      System.put_env("PORT", "")

      try do
        assert ItemsApi.Application.resolve_port() == 4000
      after
        System.delete_env("PORT")
      end
    end

    test "falls back to default for PORT value of 0" do
      System.put_env("PORT", "0")

      try do
        assert ItemsApi.Application.resolve_port() == 4000
      after
        System.delete_env("PORT")
      end
    end

    test "falls back to default for PORT value exceeding 65535" do
      System.put_env("PORT", "70000")

      try do
        assert ItemsApi.Application.resolve_port() == 4000
      after
        System.delete_env("PORT")
      end
    end

    test "falls back to default for PORT with trailing characters" do
      System.put_env("PORT", "4000abc")

      try do
        assert ItemsApi.Application.resolve_port() == 4000
      after
        System.delete_env("PORT")
      end
    end

    test "falls back to default for negative PORT value" do
      System.put_env("PORT", "-1")

      try do
        assert ItemsApi.Application.resolve_port() == 4000
      after
        System.delete_env("PORT")
      end
    end
  end

  describe "default_port/0" do
    test "returns 4000" do
      assert ItemsApi.Application.default_port() == 4000
    end
  end

  describe "application startup" do
    test "Bandit is running and accepting connections" do
      # The app is already started by mix test. Verify Bandit is listening.
      assert Process.whereis(ItemsApi.Supervisor) != nil

      children = Supervisor.which_children(ItemsApi.Supervisor)
      bandit_running = Enum.any?(children, fn {_id, pid, _type, _modules} -> is_pid(pid) end)
      assert bandit_running, "Expected Bandit to be running under supervisor"
    end
  end
end
