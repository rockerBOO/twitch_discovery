defmodule TwitchDiscovery.View.Helpers do
  use Timex

  defmacro __using__(_) do
    quote do
      def logged_in?() do
        TwitchDiscovery.Session.logged_in?()
      end

      def number_format(number) do
        Number.Delimit.number_to_delimited(number)
      end

      def button_toggle_mui(is_active_page?) do
        if is_active_page? do
          "accent"
        else
          "primary"
        end
      end

      def format_time(time) do
        DateFormat.parse!(time, "{ISOz}")
        |> DateFormat.format!("{ISOdate} {kitchen}")
      end

      def selected(option, selected) when is_integer(option) and is_binary(selected) do
        int = case Integer.parse(selected) do
          {int, _} -> int
          :error -> nil
        end

        selected(option, int)
      end

      def selected(option, selected) do
        if option == selected do
          " selected=\"selected\""
        else
          ""
        end
      end

      def checked(option, checked) do
        if option == checked do
          " checked"
        else
          ""
        end
      end

      def is_active_page?(url, conn) do
        parts = String.split(url, "/")

        if parts == conn.path_info do
          true
        else
          false
        end
      end

      def cutoff(title) do
        if title == nil do
          title
        else
          cutoff_string(title)
        end
      end

      def cutoff_string(str) do
        byte_size = byte_size(str)
        string_size = String.length(str)

        case String.length(str) do
          x when x in 0..23 -> str
          _ -> String.slice(str, 0..23) <> " ..."
        end
      end
    end
  end
end