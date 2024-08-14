# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.MultiLanguage do
  def good_locale_code?(code) when is_binary(code), do: code =~ ~r<^[a-zA-Z0-9\-]+$>

  def good_locale_code?(_code), do: false

  def validate_map(%{} = object) do
    {status, data} =
      object
      |> Enum.reduce({:ok, %{}}, fn
        {lang, value}, {status, acc} when is_binary(lang) and is_binary(value) ->
          if good_locale_code?(lang) do
            {status, Map.put(acc, lang, value)}
          else
            {:modified, acc}
          end

        _, {_status, acc} ->
          {:modified, acc}
      end)

    if data == %{} do
      {status, nil}
    else
      {status, data}
    end
  end

  def validate_map(_), do: {:error, nil}

  def str_to_map(data, opts \\ []) do
    with lang when is_binary(lang) <- opts[:lang],
         true <- good_locale_code?(lang) do
      %{lang => data}
    else
      _ ->
        %{"und" => data}
    end
  end
end
