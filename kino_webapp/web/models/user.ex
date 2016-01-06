defmodule KinoWebapp.User do
  use KinoWebapp.Web, :model

  schema "users" do
    has_many :posts, KinoWebapp.Post
    field :email, :string
    field :username, :string
    field :public_key, :string

    timestamps
  end

  @required_fields ~w(email username public_key)
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
