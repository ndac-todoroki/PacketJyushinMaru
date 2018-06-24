defmodule PacketJyushinMaru do
  @moduledoc """
  Documentation for PacketJyushinMaru.
  """

  alias PacketJyushinMaru.RTP

  @typedoc """
  The UDP payload data.
  """
  @type data :: String.t

  @type reason :: atom | String.t

  @typedoc """
  A tuple according to the UDP packet parse success/failure.
  """
  @type udp_tuple :: {:ok, {data, term}} | {:error, term}

  @doc """
  Starts the UDP server at the given port
  and returns a stream of the received packets.

  ## Example

      iex> PacketJyushinMaru.stream(4000)
      ...> |> Enum.take(5)

      [
        ok: {"Test UDP packet 1", {{127, 0, 0, 1}, 43730}},
        ok: {"Test UDP packet 2", {{127, 0, 0, 1}, 43730}},
        ok: {"Test UDP packet 3", {{127, 0, 0, 1}, 43730}},
        ok: {"Test UDP packet 4", {{127, 0, 0, 1}, 43730}},
        ok: {"Test UDP packet 5", {{127, 0, 0, 1}, 43730}}
      ]

  """
  @spec stream() :: Enumerable.t
  def stream, do: stream(4444)

  @spec stream(non_neg_integer) :: Enumerable.t
  def stream(port) do
    Stream.resource(
      fn -> Socket.UDP.open!(port) end,
      fn server ->
        result =
          server
          |> Socket.Datagram.recv()
        {[result], server}
      end,
      fn server -> Socket.Stream.close(server) end
    )
  end

  @doc """
  Parses the data and converts to a struct if the
  udp payload is a valid RTP packet.

  ## Example

      PacketJyushinMaru.stream()
      |> Stream.map(&PacketJyushinMaru.parse_packet/1)
      |> Enum.take(3)

  """
  @spec parse_packet(udp_tuple) :: {:ok, RTP.t} | {:error, {reason, data}}
  def parse_packet({:ok, {data, _client}}) do
    with {:ok, struct} <- RTP.new(data) do
      {:ok, struct}
    else
      {:error, error} ->
        {:error, {error, data}}
    end
  end
  def parse_packet(error), do: error
end
