# Pleroma: A lightweight social networking server
# Copyright © 2017-2021 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Pleroma.Web.PleromaAPI.GroupController do
  use Pleroma.Web, :controller

  import Pleroma.Web.ControllerHelper,
    only: [try_render: 3, add_link_headers: 2, embed_relationships?: 1]

  alias Pleroma.Group
  alias Pleroma.Pagination
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.MastodonAPI.FallbackController
  alias Pleroma.Web.OAuth.Token
  alias Pleroma.Web.Plugs.OAuthScopesPlug

  action_fallback(Pleroma.Web.MastodonAPI.FallbackController)

  plug(
    OAuthScopesPlug,
    %{scopes: ["write:groups"]} when action in [:create, :join, :leave]
  )

  plug(
    OAuthScopesPlug,
    %{scopes: ["read:groups"]} when action in [:index, :show, :memberships, :relationships]
  )

  plug(Pleroma.Web.ApiSpec.CastAndValidate)

  defdelegate open_api_operation(action), to: Pleroma.Web.ApiSpec.GroupOperation

  def index(%{assigns: %{user: %User{} = user}} = conn, _) do
    %{joined_groups: groups} =
      user
      |> Repo.preload(:joined_groups)

    render(conn, "index.json", %{groups: groups})
  end

  def create(%{assigns: %{user: %User{} = user}, body_params: params} = conn, _) do
    params = %{
      slug: params[:slug],
      name: params[:display_name],
      description: params[:note],
      locked: params[:locked],
      privacy: params[:privacy],
      owner_id: user.id
    }

    with {:ok, %Group{} = group} <- Group.create(params) do
      render(conn, "show.json", %{group: group})
    end
  end

  def show(%{assigns: %{user: %User{}}} = conn, %{id: id}) do
    with %Group{} = group <- Group.get_by_slug_or_id(id) do
      render(conn, "show.json", %{group: group})
    end
  end

  def join(%{assigns: %{user: %User{} = user}} = conn, %{id: id}) do
    with %Group{} = group <- Group.get_by_id(id),
         {:ok, _, _, _} <- CommonAPI.join(user, group) do
      render(conn, "relationship.json", %{user: user, group: group})
    end
  end

  def leave(%{assigns: %{user: %User{} = user}} = conn, %{id: id}) do
    with %Group{} = group <- Group.get_by_id(id),
         {:ok, _, _, _} <- CommonAPI.leave(user, group) do
      render(conn, "relationship.json", %{user: user, group: group})
    end
  end

  def relationships(%{assigns: %{user: %User{} = user}} = conn, %{id: id}) do
    groups = Group.get_all_by_ids(List.wrap(id))
    render(conn, "relationships.json", user: user, groups: groups)
  end

  defp get_members_paginated(%Group{} = group, params) do
    group
    |> Group.get_members_query(params[:role])
    |> Pagination.fetch_paginated(params)
  end

  def memberships(%{assigns: %{user: %User{} = user}} = conn, %{id: id} = params) do
    with %Group{} = group <- Group.get_by_id(id) do
      params = normalize_params(params)
      members = get_members_paginated(group, params)

      conn
      |> add_link_headers(members)
      |> render("memberships.json",
        for: user,
        users: members,
        group: group,
        as: :user,
        embed_relationships: embed_relationships?(params)
      )
    else
      nil -> FallbackController.call(conn, {:error, :not_found}) |> halt()
    end
  end

  defp normalize_params(params) do
    params
    |> Enum.map(fn {key, value} -> {to_string(key), value} end)
    |> Enum.into(%{})
  end
end
