# Pleroma: A lightweight social networking server
# Copyright © 2017-2020 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.CommonValidations do
  import Ecto.Changeset

  alias Pleroma.Activity
  alias Pleroma.Object
  alias Pleroma.User

  def validate_any_presence(cng, fields) do
    non_empty =
      fields
      |> Enum.map(fn field -> get_field(cng, field) end)
      |> Enum.any?(fn
        [] -> false
        _ -> true
      end)

    if non_empty do
      cng
    else
      fields
      |> Enum.reduce(cng, fn field, cng ->
        cng
        |> add_error(field, "none of #{inspect(fields)} present")
      end)
    end
  end

  def validate_actor_presence(cng, options \\ []) do
    field_name = Keyword.get(options, :field_name, :actor)

    cng
    |> validate_change(field_name, fn field_name, actor ->
      if User.get_cached_by_ap_id(actor) do
        []
      else
        [{field_name, "can't find user"}]
      end
    end)
  end

  def validate_actor_is_active(cng, options \\ []) do
    field_name = Keyword.get(options, :field_name, :actor)

    cng
    |> validate_change(field_name, fn field_name, actor ->
      if %User{deactivated: false} = User.get_cached_by_ap_id(actor) do
        []
      else
        [{field_name, "can't find user (or deactivated)"}]
      end
    end)
  end

  def validate_object_presence(cng, options \\ []) do
    field_name = Keyword.get(options, :field_name, :object)
    allowed_types = Keyword.get(options, :allowed_types, false)

    cng
    |> validate_change(field_name, fn field_name, object_id ->
      object = Object.get_cached_by_ap_id(object_id) || Activity.get_by_ap_id(object_id)

      cond do
        !object ->
          [{field_name, "can't find object"}]

        object && allowed_types && object.data["type"] not in allowed_types ->
          [{field_name, "object not in allowed types"}]

        true ->
          []
      end
    end)
  end

  def validate_object_or_user_presence(cng, options \\ []) do
    field_name = Keyword.get(options, :field_name, :object)
    options = Keyword.put(options, :field_name, field_name)

    actor_cng =
      cng
      |> validate_actor_presence(options)

    object_cng =
      cng
      |> validate_object_presence(options)

    if actor_cng.valid?, do: actor_cng, else: object_cng
  end

  def validate_host_match(cng, fields \\ [:id, :actor]) do
    unique_hosts =
      fields
      |> Enum.map(fn field ->
        %URI{host: host} =
          cng
          |> get_field(field)
          |> URI.parse()

        host
      end)
      |> Enum.uniq()
      |> Enum.count()

    if unique_hosts == 1 do
      cng
    else
      fields
      |> Enum.reduce(cng, fn field, cng ->
        cng
        |> add_error(field, "hosts of #{inspect(fields)} aren't matching")
      end)
    end
  end
end
