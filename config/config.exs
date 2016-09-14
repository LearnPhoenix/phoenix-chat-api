# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :phoenix_chat,
  ecto_repos: [PhoenixChat.Repo]

# Configures the endpoint
config :phoenix_chat, PhoenixChat.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "I9z4ZZUP4CQ5sPHpWqHtx+QHf7D2Z4m2kZ8Ln/6nglVfLAlCsAWOXAQ2F1iuDxzM",
  render_errors: [view: PhoenixChat.ErrorView, accepts: ~w(html json)],
  pubsub: [name: PhoenixChat.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

config :ueberauth, Ueberauth,
  providers: [
    identity: {
      Ueberauth.Strategy.Identity,
      [callback_methods: ["POST"]]
    }
  ]

config :guardian, Guardian,
  issuer: "PhoenixChat",
  ttl: {30, :days},
  secret_key: "u8zSJLoclxh5cj/Pv2rVaiAbu1jxORtPV5Zz1CpojxlwsbJQa9fJ7VsBkGfeO5R/",
  serializer: PhoenixChat.GuardianSerializer,
  permissions: %{default: [:read, :write]}
