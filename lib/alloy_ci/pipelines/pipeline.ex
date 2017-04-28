defmodule AlloyCi.Pipeline do
  @moduledoc """
  """
  use AlloyCi.Web, :model

  schema "pipelines" do
    field :before_sha, :string
    field :commit, :map
    field :duration, :integer
    field :finished_at, :naive_datetime
    field :installation_id, :integer
    field :ref, :string
    field :sha, :string
    field :started_at, :naive_datetime
    field :status, :string, default: "pending"

    belongs_to :project, AlloyCi.Project
    has_many :builds, AlloyCi.Build

    timestamps()
  end

  @required_fields ~w(project_id ref sha before_sha commit installation_id)a
  @optional_fields ~w(started_at finished_at duration status)a

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> unique_constraint(:sha, name: :pipelines_project_id_sha_index)
  end
end