defmodule TwitchDiscovery.Metric.Channel do
  use Timex

# TwitchDiscovery.Metric.Channel.save("test", 1)

# timestamp_minute: ISODate("2013-10-10T23:06:00.000Z"),
#   type: “memory_used”,
#   values: {
#     0: 999999,
#     …
#     37: 1000000,
#     38: 1500000,
#     …
#     59: 2000000
#   }

  def save(channel, type, value) do
    :calendar.universal_time

    date = Date.now |> DateFormat.format!("{s-epoch}")

    {date, _} = Integer.parse(date)

    update = %{
      "timestamp" => %BSON.DateTime{utc: date},
      "channel"   => channel,
      "type"      => type,
      "value"     => value
    }

    MongoPool.run(fn (conn) ->
      conn |> Mongo.Connection.insert("test", update)
    end)
  end
end