# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.CommonAPI.ActivityDraftTest do
  use Pleroma.DataCase

  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.CommonAPI.ActivityDraft

  import Pleroma.Factory

  describe "multilang processing" do
    setup do
      [user: insert(:user)]
    end

    test "content", %{user: user} do
      {:ok, draft} =
        ActivityDraft.create(user, %{
          status_map: %{"a" => "mew mew", "b" => "lol lol"},
          spoiler_text_map: %{"a" => "mew", "b" => "lol"},
          language: "a"
        })

      assert %{
               "contentMap" => %{"a" => "mew mew", "b" => "lol lol"},
               "content" => content,
               "summaryMap" => %{"a" => "mew", "b" => "lol"},
               "summary" => summary
             } = draft.object

      assert is_binary(content)
      assert is_binary(summary)
    end
  end

  test "create/2 with a quote post" do
    user = insert(:user)
    another_user = insert(:user)

    {:ok, direct} = CommonAPI.post(user, %{status: ".", visibility: "direct"})
    {:ok, private} = CommonAPI.post(user, %{status: ".", visibility: "private"})
    {:ok, unlisted} = CommonAPI.post(user, %{status: ".", visibility: "unlisted"})
    {:ok, local} = CommonAPI.post(user, %{status: ".", visibility: "local"})
    {:ok, public} = CommonAPI.post(user, %{status: ".", visibility: "public"})

    {:error, _} = ActivityDraft.create(user, %{status: "nice", quote_id: direct.id})
    {:ok, _} = ActivityDraft.create(user, %{status: "nice", quote_id: private.id})
    {:error, _} = ActivityDraft.create(another_user, %{status: "nice", quote_id: private.id})
    {:ok, _} = ActivityDraft.create(user, %{status: "nice", quote_id: unlisted.id})
    {:ok, _} = ActivityDraft.create(another_user, %{status: "nice", quote_id: unlisted.id})
    {:ok, _} = ActivityDraft.create(user, %{status: "nice", quote_id: local.id})
    {:ok, _} = ActivityDraft.create(another_user, %{status: "nice", quote_id: local.id})
    {:ok, _} = ActivityDraft.create(user, %{status: "nice", quote_id: public.id})
    {:ok, _} = ActivityDraft.create(another_user, %{status: "nice", quote_id: public.id})
  end
end
