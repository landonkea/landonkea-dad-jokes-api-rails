# A Category groups jokes by topic, "puns", "animals", "food", and so on.
# It exists mostly so the browse page can offer a filter dropdown and so the
# stats page can show a per-topic breakdown without hardcoding a list of
# strings anywhere in the app.
class Category < ApplicationRecord
  # One category has many jokes. If a category were ever destroyed, its jokes
  # shouldn't just vanish silently, so we tell Rails to refuse the delete
  # instead (:restrict_with_error) rather than cascading and wiping out jokes.
  has_many :jokes, dependent: :restrict_with_error

  # Every category needs a name, and no two categories can share one (the
  # database's unique index backs this up too, this check just gives a nicer
  # error message before the query ever runs).
  validates :name, presence: true, uniqueness: true

  # Returns categories ordered alphabetically, this is the friendliest order
  # for a dropdown or a list of filter buttons, easier to scan than insertion order.
  scope :alphabetical, -> { order(:name) }
end
