defmodule ItemsApi.Item do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {Jason.Encoder, only: [:id, :name, :description, :inserted_at]}

  schema "items" do
    field :name, :string
    field :description, :string, default: ""

    timestamps(type: :utc_datetime, updated_at: false)
  end

  def changeset(item, attrs) do
    item
    |> cast(attrs, [:name, :description])
    |> validate_required([:name], message: "name is required")
  end
end
