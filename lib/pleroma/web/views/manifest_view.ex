# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ManifestView do
  use Pleroma.Web, :view
  alias Pleroma.Config
  alias Pleroma.Web.Endpoint

  def render("manifest.json", _params) do
    %{
      name: Config.get([:instance, :name]),
      description: Config.get([:instance, :description]),
      icons: Config.get([:manifest, :icons]),
      theme_color:
        Config.get(
          [:frontend_configurations, :pl_fe, "brandColor"],
          Config.get([:manifest, :theme_color])
        ),
      background_color: Config.get([:manifest, :background_color]),
      display: "standalone",
      display_override: ["window-controls-overlay"],
      scope: Endpoint.url(),
      start_url: "/",
      categories: [
        "social"
      ],
      serviceworker: %{
        src: "/sw.js"
      },
      share_target: %{
        action: "share",
        method: "GET",
        params: %{
          title: "title",
          text: "text",
          url: "url"
        }
      },
      shortcuts: [
        %{
          name: "Search",
          url: "/search",
          icons: [
            %{
              src: "/images/shortcuts/search.png",
              sizes: "192x192"
            }
          ]
        },
        %{
          name: "Notifications",
          url: "/notifications",
          icons: [
            %{
              src: "/images/shortcuts/notifications.png",
              sizes: "192x192"
            }
          ]
        },
        %{
          name: "Chats",
          url: "/chats",
          icons: [
            %{
              src: "/images/shortcuts/chats.png",
              sizes: "192x192"
            }
          ]
        }
      ]
    }
  end
end
