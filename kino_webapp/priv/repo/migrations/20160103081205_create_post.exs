defmodule KinoWebapp.Repo.Migrations.CreatePost do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :key, :text
      add :content, :text

      timestamps
    end

    create index(:posts, [:key], unique: true)
  end
end
