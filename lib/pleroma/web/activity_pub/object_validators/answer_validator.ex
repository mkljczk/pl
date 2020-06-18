# Pleroma: A lightweight social networking server
# Copyright © 2017-2020 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Pleroma.Web.ActivityPub.ObjectValidators.AnswerValidator do
  use Ecto.Schema

  alias Pleroma.Web.ActivityPub.ObjectValidators.CommonValidations
  alias Pleroma.Web.ActivityPub.ObjectValidators.Types

  import Ecto.Changeset

  @primary_key false
  @derive Jason.Encoder

  embedded_schema do
    field(:id, Types.ObjectID, primary_key: true)
    field(:to, {:array, :string}, default: [])
    field(:cc, {:array, :string}, default: [])

    # is this actually needed?
    field(:bto, {:array, :string}, default: [])
    field(:bcc, {:array, :string}, default: [])

    field(:type, :string)
    field(:name, :string)
    field(:inReplyTo, :string)
    field(:attributedTo, Types.ObjectID)
    field(:actor, Types.ObjectID)
  end

  def cast_and_apply(data) do
    data
    |> cast_data()
    |> apply_action(:insert)
  end

  def cast_and_validate(data) do
    data
    |> cast_data()
    |> validate_data()
  end

  def cast_data(data) do
    %__MODULE__{}
    |> changeset(data)
  end

  def changeset(struct, data) do
    struct
    |> cast(data, __schema__(:fields))
  end

  def validate_data(data_cng) do
    data_cng
    |> validate_inclusion(:type, ["Answer"])
    |> validate_required([:id, :inReplyTo, :name])
    |> CommonValidations.validate_any_presence([:cc, :to])
    |> CommonValidations.validate_actor_presence()
  end
end
