# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MultiLanguageTest do
  use Pleroma.DataCase, async: true

  alias Pleroma.MultiLanguage

  describe "str_to_map" do
    test "" do
      assert MultiLanguage.str_to_map("foo") == %{"und" => "foo"}
    end
  end
end
