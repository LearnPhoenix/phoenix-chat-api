defmodule PhoenixChat.AuthController do
  use PhoenixChat.Web, :controller

  def test(conn, _params) do
    IO.puts "AuthController called!"
    conn
  end
end
