# This migration builds the "jokes" table, the heart of the whole app: every
# dad joke that's been submitted lives here, along with its vote counts.
class CreateJokes < ActiveRecord::Migration[8.1]
  def change
    create_table :jokes do |t|
      # The setup is the first line of the joke, the part that sets up the punchline.
      t.text :setup, null: false
      # The punchline is the payoff line that (hopefully) makes someone groan.
      t.text :punchline, null: false
      # Every joke belongs to one category. "foreign_key: true" tells SQLite to
      # enforce that a joke's category_id always points at a real row in the
      # categories table, so we can never end up with an orphaned joke.
      t.references :category, null: false, foreign_key: true
      # How groan-worthy the joke is, on a 1-10 scale. Defaults to 5 (the
      # middle of the scale) so a joke created without one still has a sane value.
      t.integer :groan_level, null: false, default: 5
      # How many people gave this joke a thumbs up. Starts at 0 for a fresh joke.
      t.integer :upvotes, null: false, default: 0
      # How many people gave this joke a thumbs down. Starts at 0 for a fresh joke.
      t.integer :downvotes, null: false, default: 0
      # Who submitted the joke. Defaults to "Anonymous Dad" so submissions that
      # skip this field still show something friendly instead of a blank space.
      t.string :author, null: false, default: "Anonymous Dad"

      t.timestamps
    end
    # Note: t.references above with foreign_key: true already creates an index
    # on category_id automatically, browsing "by category" runs a WHERE on
    # that column constantly, so that index keeps the lookup fast without us
    # needing to add a second, duplicate one here.
    #
    # The stats page and the "top voted" sort both care about net score, so an
    # index on the combination of the two vote columns helps the database sort
    # by (upvotes - downvotes) without scanning every row.
    add_index :jokes, [:upvotes, :downvotes]
  end
end
