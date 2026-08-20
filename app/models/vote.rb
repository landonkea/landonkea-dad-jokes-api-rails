# A Vote records one upvote or downvote cast by one visitor on one joke.
# Keeping every vote as its own row (rather than just incrementing a counter)
# is what lets us enforce "one vote per person per joke."
class Vote < ApplicationRecord
  # Every vote is cast on exactly one joke.
  belongs_to :joke

  # vote_type can only ever be "up" or "down", nothing else makes sense here.
  validates :vote_type, presence: true, inclusion: { in: %w[up down] }
  # We always need to know who voted (by IP address) so we can block a repeat vote.
  validates :voter_ip, presence: true
  # This is the "no double voting" rule: the same voter_ip can't have two vote
  # rows for the same joke_id. Rails checks this before saving, and the
  # unique index from the migration backs it up at the database level too, in
  # case two votes race in at nearly the same moment.
  validates :voter_ip, uniqueness: { scope: :joke_id, message: "has already voted on this joke" }
end
