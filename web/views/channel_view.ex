defmodule TwitchDiscovery.ChannelView do
  use TwitchDiscovery.Web, :view

  # DUPLICATE OF stream_view.exe
  def cutoff(title) do
    if title == nil do
      title
    else
      cutoff_string(title)
    end
  end

  # DUPLICATE OF stream_view.exe
  def cutoff_string(str) do
    byte_size = byte_size(str)
    string_size = String.length(str)

    case String.length(str) do
      x when x in 0..23 -> str
      _ -> String.slice(str, 0..23) <> " ..."
    end
  end
end
