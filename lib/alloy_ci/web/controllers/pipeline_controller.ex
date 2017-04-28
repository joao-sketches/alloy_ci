defmodule AlloyCi.Web.PipelineController do
  use AlloyCi.Web, :controller

  alias AlloyCi.{Pipeline, Pipelines}
  plug EnsureAuthenticated, handler: AlloyCi.Web.AuthController, typ: "access"

  def index(conn, %{"project_id" => project_id}, current_user, _claims) do
    case Pipelines.list_pipelines(project_id, current_user) do
      {:ok, pipelines} ->
        render(conn, "index.html", pipelines: pipelines, current_user: current_user)
      {:error, nil} ->
        conn
        |> put_flash(:info, "Project not found")
        |> redirect(to: project_path(conn, :index))
    end
  end

  def show(conn, %{"id" => id, "project_id" => project_id}, current_user, _claims) do
    case Pipelines.get_pipeline!(id, project_id, current_user) do
      %Pipeline{} = pipeline ->
        render(conn, "show.html", pipeline: pipeline, current_user: current_user)
      {:error, nil} ->
        conn
        |> put_flash(:info, "Project not found")
        |> redirect(to: project_path(conn, :index))
    end
  end
end