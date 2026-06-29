# Sessy

Self-hosted Amazon SES email observability, packaged as a mountable Rails engine.

Sessy ingests SES event notifications (deliveries, bounces, complaints, opens,
clicks, …) over SNS and gives you a dashboard to inspect them — deliverability at a
glance, per-message timelines, bounce/complaint breakdowns. It's an isolated engine
you drop into an existing Rails app; no separate service to deploy.

This is Medulla's fork of [marckohlbrugge/sessy](https://github.com/marckohlbrugge/sessy),
converted from a standalone app into a reusable engine.

## Installation

```ruby
gem "sessy", github: "medulla-app/sessy"
```

```bash
bundle install
bin/rails sessy:install:migrations
bin/rails db:migrate
```

Supported databases: **PostgreSQL** and **SQLite** (the suite runs against both).
MySQL is not supported — the dashboard's aggregate queries use `||` string
concatenation.

## Mounting

```ruby
# config/routes.rb
mount Sessy::Engine => "/sessy"

# The SNS webhook lives OUTSIDE the engine mount (and any auth wrapper) so SNS can
# reach it. Point one route at the webhook controller:
post "/sessy/webhooks/:source_token", to: "sessy/webhooks#create"
```

## Authentication

The engine ships with no auth. Gate the **dashboard** (the webhook is always exempt —
its auth is the SNS signature + per-source token) using any of:

```ruby
# 1. Inherit from one of your own controllers (Blazer / Mission Control style):
Sessy.parent_controller = "AdminController"

# 2. A quick before_action gate:
Sessy.authenticate = -> { head :forbidden unless current_user&.admin? }
```

```ruby
# 3. Wrap the mount (e.g. Devise):
authenticate :user, ->(u) { u.admin? } do
  mount Sessy::Engine => "/sessy"
end
```

## Connecting SES → SNS

1. Create an SES configuration set with an SNS event destination.
2. Stamp outgoing mail with `X-SES-CONFIGURATION-SET: <your-set>`.
3. Pick a token. Either create a source in the dashboard, or — for a zero-setup
   single-source deploy — set `Sessy.auto_source_token = ENV["SESSY_SOURCE_TOKEN"]`
   and the source is created automatically on the first webhook. Any other unknown
   token still 404s. Set `Sessy.auto_source_retention_days` to bound how long that
   source keeps events (otherwise it retains them indefinitely).
4. Subscribe the SNS topic (HTTPS) to `https://<host>/sessy/webhooks/<token>`. Sessy
   auto-confirms the subscription.

## Rebuilding the dashboard CSS

The dashboard CSS ships precompiled at `app/assets/builds/sessy.css` so host apps
need no Tailwind toolchain. To rebuild after changing views:

```bash
bundle exec tailwindcss -i app/assets/tailwind/application.css -o app/assets/builds/sessy.css --minify
```

## License

Open source under the [MIT License](https://opensource.org/licenses/MIT).
