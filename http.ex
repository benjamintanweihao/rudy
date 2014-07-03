defmodule HTTP do

  def parse_request(r0) do
    {request, r1} = request_line(r0)
    {headers, r2} = headers(r1)
    {body, _ }    = message_body(r2)
    {request, headers, body}
  end

  def request_line(<<"GET ", r0::binary>>) do
    {uri, r1}              = request_uri(r0)
    {ver, r2}              = http_version(r1)
    <<"\r\n", r3::binary>> = r2
    {{:get, uri, ver}, r3}
  end

  def request_uri(request) do
    [url, rest] = String.split(request, " ", parts: 2)
    {url, rest}
  end

  def http_version(<<"HTTP/1.1", r::binary>>), do: {:v11, r}
  def http_version(<<"HTTP/1.0", r::binary>>), do: {:v10, r}

  def headers(r) do
    [headers, rest] = r |> String.split("\r\n\r\n", parts: 2)
    {headers, rest}
  end

  def message_body(r) do
    {r, []}
  end

  def ok(body), do: "HTTP/1.1 200 OK\r\n\r\n#{body}"
  def get(uri), do: "GET #{uri} HTTP/1.1\r\n\r\n\r\n"

end

# IO.inspect HTTP.request_line("GET /foo HTTP/1.1\r\nHost: localhost:8082\r\nConnection: keep-alive\r\nAccept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8\r\nUser-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/35.0.1916.153 Safari/537.36\r\nAccept-Encoding: gzip,deflate,sdch\r\nAccept-Language: en-US,en;q=0.8\r\n\r\n")
# request = "GET /index.html HTTP/1.1\r\nfoo 34\r\n\r\nHello"
# IO.inspect HTTP.parse_request(request)

