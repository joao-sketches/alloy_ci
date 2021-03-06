defmodule AlloyCi.Web do
  @moduledoc """
  A module that keeps using definitions for controllers,
  views and so on.

  This can be used in your application as:

      use AlloyCi.Web, :controller
      use AlloyCi.Web, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below.
  """

  def schema do
    quote do
      use Ecto.Schema

      import Ecto.Changeset
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, namespace: AlloyCi.Web
      use Guardian.Phoenix.Controller

      alias Guardian.Plug.{EnsureAuthenticated, EnsurePermissions}

      import AlloyCi.Web.{Gettext, Router.Helpers, Controller.Helpers}
    end
  end

  def admin_controller do
    quote do
      use Phoenix.Controller, namespace: AlloyCi.Web.Admin
      use Guardian.Phoenix.Controller, key: :admin

      alias Guardian.Plug.{EnsureAuthenticated, EnsurePermissions}

      import AlloyCi.Web.{Router.Helpers, Controller.Helpers}
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/alloy_ci/web/templates",
        namespace: AlloyCi.Web

      # Import convenience functions from controllers
      import Phoenix.Controller, only: [get_csrf_token: 0, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import AlloyCi.Web.Router.Helpers
      import AlloyCi.Web.{ErrorHelpers, Gettext, InputHelpers, ViewHelpers}
    end
  end

  def router do
    quote do
      use Phoenix.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
