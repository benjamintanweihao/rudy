defmodule Benchmark do

  def bench(host, port) do
    start = :erlang.now
    run(100, host, port)
    finish = :erlang.now
    :timer.now_diff(finish, start)
  end

  def run(n, host, port) do
    cond do
      n == 0 -> :ok
      true ->
        request(host, port)
        run(n-1, host, port)
    end
  end

  def request(host, port) do
    opts = [:list, {:active, false}, {:reuseaddr, true}]
    {:ok, server} = :gen_tcp.connect(host, port, opts)
    :gen_tcp.send(server, HTTP.get("foo"))

    case :gen_tcp.recv(server, 0) do
      {:ok, _} ->
        :ok
      {:error, error} ->
        IO.puts "test: error: #{inspect error}"
    end
  end

end

Benchmark.bench('localhost', 8086)
