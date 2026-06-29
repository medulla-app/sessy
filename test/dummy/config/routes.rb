Rails.application.routes.draw do
  mount Sessy::Engine => "/admin/sessy"

  # Public SNS webhook — mounted outside the engine (and any auth wrapper) so SNS
  # can reach it. Mirrors how a host app wires it up.
  post "/sessy/webhooks/:source_token", to: "sessy/webhooks#create"
end
