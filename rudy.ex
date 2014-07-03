defmodule Rudy do
  require HTTP

  def start(port) do
    Process.register(spawn(__MODULE__, :init, [port]), __MODULE__)
  end

  def stop do
    __MODULE__
      |> Process.whereis
      |> Process.exit(:kill)
  end

  def init(port) do
    # initializes the server
    # takes a port
    # opens a listening socket
    # passes the socket to handler/1
    opts = [:list, {:active, false}, {:reuseaddr, true}]
    case :gen_tcp.listen(port, opts) do
      {:ok, listen} ->
        IO.puts "Listening on port #{port}"
        handler(listen)
        :gen_tcp.close(listen)
      {:error, error} ->
        IO.inspect error
    end
  end

  def handler(listen) do
    # listen to the socket for an incoming connection
    # once connected, handler/1 passes the connection to
    # request/1
    case :gen_tcp.accept(listen) do
      {:ok, client} ->
        IO.puts "Client connected"
        request(client)
      {:error, error} ->
        IO.inspect error
    end
    handler(listen)
  end

  def request(client) do
    # read the request from the client connection and parse it
    # parsed request is then handed over to reply
    recv = case :gen_tcp.recv(client, 0) do
             {:ok, str} ->
               IO.puts "request: #{str}"
               request = HTTP.parse_request("#{str}")
               response = reply(request)
               :gen_tcp.send(client, response)
             {:error, error} ->
               IO.inspect error
           end
    :gen_tcp.close(client)
  end

  def reply({{:get, uri, _}, _, body}) do
    HTTP.ok(body)
  end

end

Rudy.start(8086)
