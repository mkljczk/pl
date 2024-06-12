# Pleroma: A lightweight social networking server
# Copyright © 2017-2021 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only
defmodule Pleroma.Web.PleromaAPI.GroupView do
  use Pleroma.Web, :view

  alias Pleroma.Activity
  alias Pleroma.Group
  alias Pleroma.Repo
  alias Pleroma.User
  alias Pleroma.Web.MastodonAPI.AccountView
  alias Pleroma.Web.MastodonAPI.StatusView
  alias Pleroma.Web.MediaProxy
  alias Pleroma.Web.PleromaAPI.GroupView

  def render("index.json", %{groups: groups}) do
    render_many(groups, __MODULE__, "show.json")
  end

  def render("show.json", %{group: %User{} = user}) do
    %{group: group} = Repo.preload(user, :group)

    render("show.json", %{group: group})
  end

  def render("show.json", %{group: %Group{} = group}) do
    group = Repo.preload(group, :user)

    avatar = User.avatar_url(group.user) |> MediaProxy.url()
    avatar_static = User.avatar_url(group.user) |> MediaProxy.preview_url(static: true)
    header = User.banner_url(group.user) |> MediaProxy.url()
    header_static = User.banner_url(group.user) |> MediaProxy.preview_url(static: true)

    %{
      id: group.id,
      display_name: group.name,
      created_at: group.inserted_at,
      note: group.description,
      uri: group.ap_id,
      url: group.ap_id,
      avatar: avatar,
      avatar_static: avatar_static,
      header: header,
      header_static: header_static,
      # domain
      locked: group.user.is_locked,
      statuses_visibility: "public",
      membership_required: true,
      acct: group.user.nickname,
      slug: group.user.nickname,
      emojis: [],
      fields: [],
      # TODO: get proper count
      members_count: Group.members(group) |> Enum.count(),
      source: %{
        fields: [],
        note: group.description || "",
        privacy: group.privacy
      }
    }
  end

  def render("show.json", _), do: nil

  def render("relationship.json", %{user: %User{} = user, group: %Group{} = group} = options) do
    membership_state = Group.get_membership_state(group, user)

    %{
      id: group.id,
      account: AccountView.render("show.json", user: user, for: options[:for_user]),
      # TODO: Make dynamic
      member: true,
      role: "users",
      requested: membership_state == :join_pending,
      owner: user.id == group.owner_id
    }
  end

  def render("relationships.json", %{user: user, groups: groups}) do
    render_many(groups, GroupView, "relationship.json", user: user)
  end

  def render("membership.json", %{user: user, group: group} = params) do
    role =
      if group.owner_id == user.id do
        "owner"
      else
        "user"
      end

    %{
      id: user.id,
      account: AccountView.render("show.json", params),
      role: role
    }
  end

  def render("memberships.json", %{users: users} = params) do
    render_many(users, GroupView, "membership.json", %{params | as: :user})
  end
end
