defmodule KinoWebapp.Repo.Migrations.CreateUser do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string
      add :username, :string
      add :public_key, :text

      timestamps
    end

    create index(:users, [:username], unique: true)
    create index(:users, [:email], unique: true)
    create index(:users, [:public_key], unique: true)
  end
end
