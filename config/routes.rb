Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # The homepage shows one random joke, so visiting the site is basically
  # rolling the dice on a dad joke, matching the original app's default tab.
  root "jokes#random"

  # "resources :jokes" would normally also generate edit/update/destroy
  # routes, but this app never edits or deletes a joke through the browser,
  # so we list only the four actions it actually uses: the browse list
  # (index), a single joke page (show), the submission form (new), and
  # saving that form (create).
  resources :jokes, only: [:index, :show, :new, :create] do
    # Nested under a specific joke, "resource" (singular) because a visitor
    # only ever casts one vote per joke, there's no list of "votes" to browse.
    # This gives us POST /jokes/:joke_id/vote, handled by VotesController.
    resource :vote, only: [:create], controller: "votes"
  end
  # A dedicated path for "give me a random joke" outside the jokes#index
  # listing, this is what the homepage and the "Another One" button both hit.
  get "random", to: "jokes#random"

  # The stats dashboard: total jokes, total votes, average groan level, the
  # most upvoted joke, and a per-category breakdown.
  get "stats", to: "stats#index"
end
