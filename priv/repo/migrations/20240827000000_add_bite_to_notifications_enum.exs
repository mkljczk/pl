defmodule Pleroma.Repo.Migrations.AddBiteToNotificationsEnum do
  use Ecto.Migration

  @disable_ddl_transaction true

  def up do
    """
    alter type notification_type add value 'bite'
    """
    |> execute()
  end

  # 20220819171321_add_pleroma_participation_accepted_to_notifications_enum.exs
  def down do
    alter table(:notifications) do
      modify(:type, :string)
    end

    """
    delete from notifications where type = 'bite'
    """
    |> execute()

    """
    drop type if exists notification_type
    """
    |> execute()

    """
    create type notification_type as enum (
      'follow',
      'follow_request',
      'mention',
      'move',
      'pleroma:emoji_reaction',
      'pleroma:chat_mention',
      'reblog',
      'favourite',
      'pleroma:report',
      'poll',
      'status',
      'update',
      'pleroma:participation_accepted',
      'pleroma:participation_request',
      'pleroma:event_reminder',
      'pleroma:event_update'
    )
    """
    |> execute()

    """
    alter table notifications
    alter column type type notification_type using (type::notification_type)
    """
    |> execute()
  end
end
