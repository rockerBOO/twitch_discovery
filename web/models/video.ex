defmodule TwitchDiscovery.Video do
  use TwitchDiscovery.Web, :model

  schema "videos" do
    field :title, :string
    field :description, :string
    field :status, :string
    field :broadcast_id, :integer
    field :channel_name, :string
    field :channel_display_name, :string

    timestamps
  end

  @required_fields ~w(title description status broadcast_id channel_name channel_display_name)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
