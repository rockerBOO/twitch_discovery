defmodule TwitchDiscovery.Query.Base do
  defmacro __using__(_) do
    quote do
      require Logger

      defoverridable Module.definitions_in(__MODULE__)
    end
  end
end