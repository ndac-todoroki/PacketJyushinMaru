defmodule PacketJyushinMaru do
  @moduledoc """
  Documentation for PacketJyushinMaru.

  ## Computing packet emitting speed/constance

  You can do as the following:

      iex> PacketJyushinMaru.stream(5004)
      ...> |> Stream.map(&PacketJyushinMaru.parse_packet/1)
      ...> |> Stream.map(&(&1 |> elem(1)))
      ...> |> Stream.map(& &1.timestamp)
      ...> |> Stream.transform(0, fn i, acc -> {[i - acc], i} end)
      ...> |> Enum.take(10)
      [12882888, 8453, 8452, 8453, 8458, 8451, 8460, 8441, 8452, 8453]

      iex> v() |> Enum.drop(1) |> (& Enum.sum(&1) / length(&1)).()
      8452.555555555555

  Although, there is a convenient function for that:

      iex> PacketJyushinMaru.stream(5004)
      ...> |> PacketJushinMaru.packet_time_mean(1000)
      8452.555555555555

  """

  alias PacketJyushinMaru.RTP

  @typedoc """
  The UDP payload data.
  """
  @type data :: String.t()

  @type reason :: atom | String.t()

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
  @spec stream() :: Enumerable.t()
  def stream, do: stream(4444)

  @spec stream(non_neg_integer) :: Enumerable.t()
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
  @spec parse_packet(udp_tuple) :: {:ok, RTP.t()} | {:error, {reason, data}}
  def parse_packet({:ok, {data, _client}}) do
    with {:ok, struct} <- RTP.new(data) do
      {:ok, struct}
    else
      {:error, error} ->
        {:error, {error, data}}
    end
  end

  def parse_packet(error), do: error

  @doc """
  ## Example

      iex(1)> import PacketJyushinMaru
      PacketJyushinMaru

      iex(2)> stream(5004) |> packet_time_mean(1000)
      578.201

      iex(3)> stream(5004) |> packet_time_mean(1000)
      607.913

  """
  @spec packet_time_mean(udp_tuple, integer) :: float
  def packet_time_mean(stream, n) do
    stream
    |> packet_time_diffs(n)
    |> (&(Enum.sum(&1) / length(&1))).()
  end

  @spec packet_time_diffs(udp_tuple, integer) :: [integer]
  def packet_time_diffs(stream, n) do
    stream
    |> Stream.map(&PacketJyushinMaru.parse_packet/1)
    |> Stream.map(&(&1 |> elem(1)))
    |> Stream.map(& &1.timestamp)
    |> Stream.transform(0, fn i, acc -> {[i - acc], i} end)
    |> Stream.drop(1)
    |> Enum.take(n)
  end
end
