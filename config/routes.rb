Sessy::Engine.routes.draw do
  # Dashboard. The SNS webhook is intentionally NOT mounted here — wire it up in
  # the host app, outside any auth wrapper, so SNS can reach it:
  #   post "/sessy/webhooks/:source_token", to: "sessy/webhooks#create"
  resources :sources, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resource :setup, only: [ :show ]
    resources :events, only: [ :index ]
    resources :messages, only: [ :show ]
  end

  root "sources#index"
end
