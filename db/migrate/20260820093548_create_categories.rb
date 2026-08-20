# This migration builds the "categories" table, the list of joke topics
# (puns, animals, food, and so on) that every joke belongs to.
class CreateCategories < ActiveRecord::Migration[8.1]
  # "change" is the one method Rails runs both when migrating up (building the
  # table) and when rolling back (Rails can figure out the reverse automatically
  # for simple stuff like this).
  def change
    # create_table starts a new database table named "categories".
    create_table :categories do |t|
      # Every category needs a name ("puns", "animals", etc). null: false means
      # the database itself will refuse to save a category with no name, that's
      # a second line of defense on top of the model validation.
      t.string :name, null: false

      # t.timestamps quietly adds "created_at" and "updated_at" columns, Rails
      # fills these in automatically whenever a row is made or changed.
      t.timestamps
    end
    # A unique index stops two categories from ever having the exact same name,
    # enforced by the database, not just by app code that could have a bug.
    add_index :categories, :name, unique: true
  end
end
