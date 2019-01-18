# Pleroma: A lightweight social networking server
# Copyright © 2017-2019 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.SpcFixesTest do
  use Pleroma.Web.ConnCase

  alias Pleroma.SpcFixes
  alias Pleroma.Web.CommonAPI
  alias Pleroma.Web.ActivityPub.ActivityPub
  alias Pleroma.User

  import Pleroma.Factory

  test "resets the ap_id and follower_address of old spc users" do
    Tesla.Mock.mock(fn
      %{url: "https://shitposter.club/users/zep"} ->
        %Tesla.Env{status: 200, body: File.read!("test/fixtures/zep.json")}

      %{url: nil} ->
        nil
    end)

    user =
      insert(:user, %{
        local: false,
        ap_id: "https://shitposter.club/user/4962",
        follower_address: User.ap_followers(%User{nickname: "zep@shitposter.club"}),
        info: %{topic: "ignore"},
        nickname: "zep@shitposter.club"
      })

    other_user = insert(:user)
    {:ok, other_user} = User.follow(other_user, user)
    {:ok, activity} = CommonAPI.post(user, %{"status" => "blabla"})

    assert User.following?(other_user, user)
    assert [activity] == ActivityPub.fetch_activities(other_user.following)

    SpcFixes.upgrade_users()

    user = Pleroma.Repo.get(User, user.id)
    other_user = Pleroma.Repo.get(User, other_user.id)

    assert user.ap_id == "https://shitposter.club/users/zep"
    assert user.follower_address == "https://shitposter.club/users/zep/followers"

    # Activites and following are correctly stitched.
    assert User.following?(other_user, user)
    assert [activity] == ActivityPub.fetch_activities(other_user.following) |> IO.inspect()
  end
end
