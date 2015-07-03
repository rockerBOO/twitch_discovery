defmodule TwitchDiscovery.Repo.Migrations.CreateVideo do
  use Ecto.Migration

  def change do
    create table(:videos) do
      add :title, :string
      add :description, :string
      add :status, :string
      add :broadcast_id, :integer
      add :channel_name, :string
      add :channel_display_name, :string

      timestamps
    end

  end
end
