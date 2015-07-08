defmodule TwitchDiscovery.View.Helpers do
 defmacro __using__(_) do
    quote do
      def logged_in?() do
        TwitchDiscovery.Session.logged_in?()
      end

      def number_format(number) do
        Number.Delimit.number_to_delimited(number)
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