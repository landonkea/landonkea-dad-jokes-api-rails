# A Joke is a single dad joke: a setup line, a punchline, a category, a
# groan-worthiness rating, and running upvote/downvote counts. This is the
# model basically everything in the app revolves around.
class Joke < ApplicationRecord
  # Every joke belongs to exactly one category (see Category for the other
  # side of this relationship).
  belongs_to :category
  # A joke can have many individual vote records. "dependent: :destroy" means
  # if a joke is ever deleted, its votes get cleaned up with it instead of
  # being left behind as orphaned rows nobody can reach.
  has_many :votes, dependent: :destroy

  # The setup has to be there, and has to be long enough to actually be a
  # setup, matches the original app's rule (5-500 characters) so a one-word
  # non-joke can't get submitted.
  validates :setup, presence: true, length: { minimum: 5, maximum: 500 }
  # The punchline's minimum is shorter (2 characters) than the setup's,
  # because some real punchlines are genuinely tiny, like "Attire." from the
  # original app's seed jokes.
  validates :punchline, presence: true, length: { minimum: 2, maximum: 500 }
  # Groan level is a 1-10 rating of how painful the joke is. Anything outside
  # that range doesn't make sense on the scale, so it's rejected.
  validates :groan_level, presence: true,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 10 }
  # Author name is optional (it defaults to "Anonymous Dad" at the database
  # level), but if someone does type one in, cap it so nobody can paste a
  # novel into the byline.
  validates :author, length: { maximum: 100 }
  # Vote counts should never go negative, this can only really happen from a
  # bug, but it's cheap insurance to have the model refuse it outright.
  validates :upvotes, :downvotes, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  # This is the fixed list of topics a joke can be filed under. It lives here
  # (rather than only as rows in the categories table) so the submission form
  # dropdown and the seed data both have one single source of truth to pull from.
  CATEGORY_NAMES = %w[classic puns animals food science math smart work geography].freeze

  # "Net score" is upvotes minus downvotes, the same popularity number the
  # original app used to rank jokes as "top voted." Written as a real Ruby
  # method (not just a SQL expression) so it also works on a joke you already
  # loaded into memory, without hitting the database again.
  def score
    upvotes - downvotes
  end

  # How "controversial" a joke is: closest to a 50/50 vote split scores
  # highest. A joke nobody has voted on yet (0 upvotes, 0 downvotes) scores 0,
  # not the maximum, an untouched joke isn't actually contested by anyone.
  # This mirrors the same fix the original Express app made to its
  # "controversial" sort (see server/src/utils/sortOptions.ts in the source repo).
  def controversial_score
    total = upvotes + downvotes
    # Guard against dividing by zero for a joke with no votes at all.
    return 0.0 if total.zero?
    [upvotes, downvotes].min.to_f / total
  end

  # Scope for the "top voted" sort (also the default browse order): highest
  # net score first. Written as raw SQL arithmetic so the database does the
  # sorting instead of pulling every row into Ruby to sort in memory.
  scope :top_voted, -> { order(Arel.sql("upvotes - downvotes DESC")) }
  # Scope for the "most groans" sort: highest groan_level first.
  scope :most_groans, -> { order(groan_level: :desc) }
  # Scope for the "oldest first" sort: earliest submissions first.
  scope :oldest_first, -> { order(created_at: :asc) }
  # Scope for the "most controversial" sort, same 50/50-closeness math as
  # controversial_score above, done in SQL so it can be combined with LIMIT
  # and OFFSET for pagination without loading the whole table.
  scope :most_controversial, -> {
    order(Arel.sql("(CAST(MIN(upvotes, downvotes) AS FLOAT) / MAX(upvotes + downvotes, 1)) DESC"))
  }

  # Turns the "sort" query-string parameter from the browse page into the
  # right scope. Falls back to top_voted for an unrecognized or missing value,
  # so a stray/old link in a bookmark never produces a database error.
  def self.sorted_by(sort_param)
    case sort_param
    when "groan" then most_groans
    when "oldest" then oldest_first
    when "controversial" then most_controversial
    else top_voted
    end
  end
end
