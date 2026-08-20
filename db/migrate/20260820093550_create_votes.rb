# This migration builds the "votes" table, a running log of every individual
# upvote and downvote cast, one row per vote, so we can tell whether a given
# visitor has already voted on a given joke.
class CreateVotes < ActiveRecord::Migration[8.1]
  def change
    create_table :votes do |t|
      # Which joke this vote was cast on. "foreign_key: true" makes SQLite
      # reject a vote that points at a joke id that doesn't exist.
      t.references :joke, null: false, foreign_key: true
      # Either "up" or "down", never anything else (the model validates this too).
      t.string :vote_type, null: false
      # The IP address of whoever voted. There's no login system in this app,
      # so the IP address is the only way we have to recognize "this is
      # probably the same visitor voting again."
      t.string :voter_ip, null: false

      t.timestamps
    end
    # This is the rule that actually stops double-voting: the database itself
    # will refuse to insert a second row with the same (joke_id, voter_ip)
    # pair. Enforcing it here, not just in Ruby code, closes a timing gap
    # where two votes arriving at nearly the same instant could otherwise
    # both sneak past a simple "have they voted already?" check.
    add_index :votes, [:joke_id, :voter_ip], unique: true
  end
end
