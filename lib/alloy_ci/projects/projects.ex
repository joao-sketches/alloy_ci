defmodule AlloyCi.Projects do
  @moduledoc """
  The boundary for the Projects system.
  """
  alias AlloyCi.{Pipelines, Project, ProjectPermission, Repo}
  import Ecto.Query

  def all(params) do
    Project |> order_by([desc: :updated_at]) |> Repo.paginate(params)
  end

  def can_access?(id, user) do
    permission =
      ProjectPermission
      |> Repo.get_by(project_id: id, user_id: user.id)

    case permission do
      %ProjectPermission{} -> true
      _ -> false
    end
  end

  def create_project(params, user) do
    Repo.transaction(fn ->
      changeset =
        Project.changeset(
          %Project{},
          Enum.into(params, %{"token" => SecureRandom.urlsafe_base64(10)})
        )

      with {:ok, project} <- Repo.insert(changeset) do
        permissions_changeset =
          ProjectPermission.changeset(
            %ProjectPermission{},
            %{project_id: project.id, repo_id: project.repo_id, user_id: user.id}
          )
        case Repo.insert(permissions_changeset) do
          {:ok, _} -> project
          {:error, changeset} -> changeset |> Repo.rollback
        end
      else
        {:error, changeset} -> changeset |> Repo.rollback
      end
    end)
  end

  def delete_project(id, user) do
    with {:ok, project} <- get_by(id, user) do
      Repo.delete(project)
    end
  end

  def get(id), do: Project |> Repo.get(id)

  def get_by(id, user) do
    permission =
      ProjectPermission
      |> Repo.get_by(project_id: id, user_id: user.id)
      |> Repo.preload(:project)

    case permission do
      %ProjectPermission{} ->
        project = permission.project |> Repo.preload(:pipelines)
        {:ok, project}
      _ -> {:error, nil}
    end
  end

  def get_by(id, user, params) do
    permission =
      ProjectPermission
      |> Repo.get_by(project_id: id, user_id: user.id)
      |> Repo.preload(:project)

    case permission do
      %ProjectPermission{} ->
        project = permission.project
        {pipelines, kerosene} = Pipelines.paginated(id, params)
        {:ok, {project, pipelines, kerosene}}
      _ -> {:error, nil}
    end
  end

  def get_by(repo_id: id) do
    Project
    |> Repo.get_by(repo_id: id)
  end

  def get_by(token: token) do
    Project
    |> Repo.get_by(token: token)
  end

  def last_status(project) do
    query = from p in "pipelines",
            where: p.project_id == ^project.id,
            order_by: [desc: :inserted_at], limit: 1,
            select: p.status
    Repo.one(query) || "unknown"
  end

  def latest(user) do
    query = from pp in ProjectPermission,
            where: pp.user_id == ^user.id,
            join: p in Project, on: p.id == pp.project_id,
            order_by: [desc: p.updated_at], limit: 5,
            select: p
    Repo.all(query)
  end

  def paginated_for(user, params) do
    query = from pp in ProjectPermission,
            where: pp.user_id == ^user.id,
            join: p in Project, on: p.id == pp.project_id,
            order_by: [desc: p.updated_at],
            select: p
    Repo.paginate(query, params)
  end

  def repo_and_project(repo_id, existing_ids) do
    result =
      existing_ids
      |> Enum.reject(fn {r_id, _} ->
        r_id != repo_id
      end)

    if Enum.empty?(result) do
      {:error, nil}
    else
      {:ok, List.first(result)}
    end
  end

  def touch(id) do
    Project
    |> Repo.get_by(id: id)
    |> Project.changeset
    |> Repo.update(force: true)
  end
end
