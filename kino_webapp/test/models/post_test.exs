defmodule KinoWebapp.PostTest do
  use KinoWebapp.ModelCase

  alias KinoWebapp.Post

  @valid_attrs %{content: "some content", key: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
