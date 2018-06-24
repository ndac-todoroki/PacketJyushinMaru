# PacketJyushinMaru

An RTP packet receiver written in Elixir. Doesn't do much.

## Usage

```elixir
## Create a server at port 4000 and convert the packets to a stream.
iex> stream = PacketJyushinMaru.stream(4000)

#Function<54.100999549/2 in Stream.resource/3>

## Get the packets
iex> stream |> Enum.take(3)

[
  ok: {"123456789012", {{127, 0, 0, 1}, 43730}},
  ok: {"123456789012", {{127, 0, 0, 1}, 43730}},
  ok: {"123456789012", {{127, 0, 0, 1}, 43730}}
]

## A simple RTP parser is included.
iex> stream
...> |> Stream.map(&PacketJyushinMaru.parse_packet/1)
...> |> Enum.take(3)

[
  ok: %PacketJyushinMaru.RTP{
    csrc_count: 1,
    extension: 1,
    marker: 0,
    padding: 1,
    payload: "",
    payload_type: 50,
    sequence_number: 13108,
    ssrc: 959459634,
    timestamp: 892745528,
    version: 0
  },
  ok: %PacketJyushinMaru.RTP{
    csrc_count: 1,
    extension: 1,
    marker: 0,
    padding: 1,
    payload: "",
    payload_type: 50,
    sequence_number: 13108,
    ssrc: 959459634,
    timestamp: 892745528,
    version: 0
  },
  ok: %PacketJyushinMaru.RTP{
    csrc_count: 1,
    extension: 1,
    marker: 0,
    padding: 1,
    payload: "",
    payload_type: 50,
    sequence_number: 13108,
    ssrc: 959459634,
    timestamp: 892745528,
    version: 0
  }
]
```
