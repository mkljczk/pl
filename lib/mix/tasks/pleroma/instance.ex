# Pleroma: A lightweight social networking server
# Copyright © 2017-2022 Pleroma Authors <https://pleroma.social/>
# SPDX-License-Identifier: AGPL-3.0-only

defmodule Mix.Tasks.Pleroma.Instance do
  use Mix.Task
  import Mix.Pleroma

  alias Pleroma.Config

  @shortdoc "Manages Pleroma instance"
  @moduledoc File.read!("docs/administration/CLI_tasks/instance.md")

  def run(["gen" | rest]) do
    {options, [], []} =
      OptionParser.parse(
        rest,
        strict: [
          force: :boolean,
          output: :string,
          output_psql: :string,
          domain: :string,
          instance_name: :string,
          admin_email: :string,
          notify_email: :string,
          dbhost: :string,
          dbname: :string,
          dbuser: :string,
          dbpass: :string,
          rum: :string,
          indexable: :string,
          db_configurable: :string,
          uploads_dir: :string,
          static_dir: :string,
          listen_ip: :string,
          listen_port: :string,
          strip_uploads_location: :string,
          read_uploads_description: :string,
          anonymize_uploads: :string,
          dedupe_uploads: :string
        ],
        aliases: [
          o: :output,
          f: :force
        ]
      )

    paths =
      [config_path, psql_path] = [
        Keyword.get(options, :output, "config/generated_config.exs"),
        Keyword.get(options, :output_psql, "config/setup_db.psql")
      ]

    will_overwrite = Enum.filter(paths, &File.exists?/1)
    proceed? = Enum.empty?(will_overwrite) or Keyword.get(options, :force, false)

    if proceed? do
      [domain, port | _] =
        String.split(
          get_option(
            options,
            :domain,
            "What domain will your instance use? (e.g pleroma.soykaf.com)"
          ),
          ":"
        ) ++ [443]

      name =
        get_option(
          options,
          :instance_name,
          "What is the name of your instance? (e.g. The Corndog Emporium)",
          domain
        )

      email =
        get_option(
          options,
          :admin_email,
          "What is your admin email address? (this will be public)"
        )

      notify_email =
        get_option(
          options,
          :notify_email,
          "What email address do you want to use for sending email notifications?",
          email
        )

      indexable =
        get_option(
          options,
          :indexable,
          "Do you want search engines to index your site? (y/n)",
          "y"
        ) === "y"

      db_configurable? = true

      dbhost = get_option(options, :dbhost, "Where will your database live?", "localhost")

      dbname = get_option(options, :dbname, "What shall we name your database?", "pleroma")

      dbuser =
        get_option(
          options,
          :dbuser,
          "What shall we name your database user?",
          "pleroma"
        )

      dbpass =
        get_option(
          options,
          :dbpass,
          "What shall be your database password?",
          :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64),
          "autogenerated"
        )

      rum_enabled = false

      listen_port =
        get_option(
          options,
          :listen_port,
          "What port will the app listen to (leave it if you are using the default setup with nginx)?",
          4000
        )

      listen_ip =
        get_option(
          options,
          :listen_ip,
          "What IP will the app listen to (leave it if you are using the default setup with nginx)?",
          "127.0.0.1"
        )

      uploads_dir =
        Keyword.get(options, :uploads_dir) ||
          Config.get([Pleroma.Uploaders.Local, :uploads])
          |> Path.expand()

      static_dir =
        Keyword.get(options, :static_dir) ||
          Config.get([:instance, :static_dir])
          |> Path.expand()

      strip_uploads_location = false

      anonymize_uploads = false

      read_uploads_description = true

      dedupe_uploads = false

      Config.put([:instance, :static_dir], static_dir)

      secret = :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64)
      jwt_secret = :crypto.strong_rand_bytes(64) |> Base.encode64() |> binary_part(0, 64)
      signing_salt = :crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)
      lv_signing_salt = :crypto.strong_rand_bytes(8) |> Base.encode64() |> binary_part(0, 8)
      {web_push_public_key, web_push_private_key} = :crypto.generate_key(:ecdh, :prime256v1)
      template_dir = Application.app_dir(:pleroma, "priv") <> "/templates"

      result_config =
        EEx.eval_file(
          template_dir <> "/sample_config.eex",
          domain: domain,
          port: port,
          email: email,
          notify_email: notify_email,
          name: name,
          dbhost: dbhost,
          dbname: dbname,
          dbuser: dbuser,
          dbpass: dbpass,
          secret: secret,
          jwt_secret: jwt_secret,
          signing_salt: signing_salt,
          lv_signing_salt: lv_signing_salt,
          web_push_public_key: Base.url_encode64(web_push_public_key, padding: false),
          web_push_private_key: Base.url_encode64(web_push_private_key, padding: false),
          db_configurable?: db_configurable?,
          static_dir: static_dir,
          uploads_dir: uploads_dir,
          rum_enabled: rum_enabled,
          listen_ip: listen_ip,
          listen_port: listen_port,
          upload_filters:
            upload_filters(%{
              strip_location: strip_uploads_location,
              read_description: read_uploads_description,
              anonymize: anonymize_uploads,
              dedupe: dedupe_uploads
            })
        )

      result_psql =
        EEx.eval_file(
          template_dir <> "/sample_psql.eex",
          dbname: dbname,
          dbuser: dbuser,
          dbpass: dbpass,
          rum_enabled: rum_enabled
        )

      config_dir = Path.dirname(config_path)
      psql_dir = Path.dirname(psql_path)

      # Note: Distros requiring group read (0o750) on those directories should
      # pre-create the directories.
      [config_dir, psql_dir, static_dir, uploads_dir]
      |> Enum.reject(&File.exists?/1)
      |> Enum.each(fn dir ->
        File.mkdir_p!(dir)
        File.chmod!(dir, 0o700)
      end)

      shell_info("Writing config to #{config_path}.")

      # Sadly no fchmod(2) equivalent in Elixir…
      File.touch!(config_path)
      File.chmod!(config_path, 0o640)
      File.write(config_path, result_config)
      shell_info("Writing the postgres script to #{psql_path}.")
      File.write(psql_path, result_psql)

      write_robots_txt(static_dir, indexable, template_dir)

      shell_info(
        "\n All files successfully written! Refer to the installation instructions for your platform for next steps."
      )

      if db_configurable? do
        shell_info(
          " Please transfer your config to the database after running database migrations. Refer to \"Transfering the config to/from the database\" section of the docs for more information."
        )
      end
    else
      shell_error(
        "The task would have overwritten the following files:\n" <>
          Enum.map_join(will_overwrite, &"- #{&1}\n") <> "Rerun with `--force` to overwrite them."
      )
    end
  end

  defp write_robots_txt(static_dir, indexable, template_dir) do
    robots_txt =
      EEx.eval_file(
        template_dir <> "/robots_txt.eex",
        indexable: indexable
      )

    robots_txt_path = Path.join(static_dir, "robots.txt")

    if File.exists?(robots_txt_path) do
      File.cp!(robots_txt_path, "#{robots_txt_path}.bak")
      shell_info("Backing up existing robots.txt to #{robots_txt_path}.bak")
    end

    File.write(robots_txt_path, robots_txt)
    shell_info("Writing #{robots_txt_path}.")
  end

  defp upload_filters(filters) when is_map(filters) do
    enabled_filters =
      if filters.strip_location do
        [Pleroma.Upload.Filter.Exiftool.StripLocation]
      else
        []
      end

    enabled_filters =
      if filters.read_description do
        enabled_filters ++ [Pleroma.Upload.Filter.Exiftool.ReadDescription]
      else
        enabled_filters
      end

    enabled_filters =
      if filters.anonymize do
        enabled_filters ++ [Pleroma.Upload.Filter.AnonymizeFilename]
      else
        enabled_filters
      end

    enabled_filters =
      if filters.dedupe do
        enabled_filters ++ [Pleroma.Upload.Filter.Dedupe]
      else
        enabled_filters
      end

    enabled_filters
  end

  defp upload_filters(_), do: []
end
