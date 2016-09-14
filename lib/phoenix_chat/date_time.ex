defmodule PhoenixChat.DateTime do
  @behaviour Ecto.Type

  def type(), do: :datetime

  def cast(milliseconds) when is_integer(milliseconds) do
    with {:ok, datetime} <- DateTime.from_unix(milliseconds, :milliseconds),
         {:ok, ecto_datetime} <- Ecto.DateTime.cast(datetime),
         do: {:ok, ecto_datetime}
  end

  def cast(value) do
    Ecto.DateTime.cast(value)
  end

  def load(value) do
    Ecto.DateTime.load(value)
  end

  def dump(value) do
    Ecto.DateTime.dump(value)
  end
end
