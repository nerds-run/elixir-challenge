defmodule ItemsApi.Repo.Migrations.CreateItemsTable do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :name, :string, null: false
      add :description, :string, null: false, default: ""
      
      timestamps(type: :utc_datetime, updated_at: false)
    end
  end
end
