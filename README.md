# Dad Jokes (Rails)

A dad-joke browsing, voting, and submission site. This is a Ruby on Rails 8 rewrite of [landonkea-dad-jokes-api](https://github.com/landonkea/landonkea-dad-jokes-api), which was originally a React frontend talking to a separate Express/PostgreSQL backend. This version is one app: Rails renders the pages directly, and a library called Hotwire/Turbo makes voting feel instant without a full page reload.

If you've never coded before, this file walks through what the app does, how the pieces fit together, and how to run it.

## What the app does

- Shows you a random dad joke on the homepage. Click "Reveal the Punchline" and it appears, along with a groan-level rating and a little reaction line.
- Lets you upvote or downvote a joke. One vote per joke per visitor, tracked by IP address (there's no login system).
- Lets you browse all the jokes, filter by category (puns, animals, food, science, and so on), and sort by top voted, most groans, oldest, or most controversial.
- Lets you submit your own joke through a form.
- Has a stats page: total jokes, total votes, average groan level, the single most upvoted joke, and a breakdown of how many jokes are in each category.

## How the pieces fit together

Rails organizes an app into a few kinds of files, each with one job:

- **Models** (`app/models/`) describe the data and the rules around it. `joke.rb` is a joke: its setup line, punchline, category, groan level, and vote counts, plus the rule that a setup needs to be at least 5 characters, a punchline at least 2. `vote.rb` is a single upvote or downvote, with the rule that the same visitor can't vote twice on the same joke. `category.rb` is a topic (puns, animals, etc.) that jokes belong to.
- **Controllers** (`app/controllers/`) handle a visitor's request and decide what to show them. `jokes_controller.rb` handles the random joke page, the browse list, the submission form, and viewing a single joke. `votes_controller.rb` handles casting a vote. `stats_controller.rb` builds the numbers for the stats page.
- **Views** (`app/views/`) are the actual HTML templates, mixed with small bits of Ruby (wrapped in `<% %>` or `<%= %>`) to fill in real data. `app/views/jokes/_joke_card.html.erb` is the reusable "one joke, with vote buttons and a reveal button" block used on a few different pages.
- **Migrations** (`db/migrate/`) are the instructions that built the database tables. `db/seeds.rb` fills a fresh database with the same 30 starter jokes the original app shipped with, so it isn't empty on first run.
- **Routes** (`config/routes.rb`) map a URL like `/jokes?category=puns` to the controller action that handles it.

## How the voting works, in plain terms

When you click an upvote button, the browser sends the vote to the server, same as any web form. Normally that would reload the whole page. Turbo intercepts that submission, sends it quietly in the background, and the server sends back just the small piece of HTML that changed (the vote counts). Turbo swaps that piece into the page. Nothing else on the page reloads or flickers. If your browser had JavaScript turned off entirely, the vote would still work, it would just do a normal full-page reload instead, since the form is a real HTML form underneath.

The "you can only vote once per joke" rule lives in the database itself, not just in the page. That's what lets your vote stay counted (and the buttons stay grayed out) even if you refresh the page or come back an hour later.

## Running it locally

You need Ruby 3.4.9 and Rails 8.1 installed (this repo was built and tested with rbenv managing the Ruby version).

```bash
bundle install
bin/rails db:setup      # creates the database, runs migrations, loads the 30 starter jokes
bin/dev                 # starts the Rails server and the Tailwind CSS watcher together
```

Then open `http://localhost:3000`.

## Running the tests

```bash
bin/rails test              # model and controller tests
bin/rails test:system       # the browser-driven voting test (needs Chrome installed)
```

Everything is real assertions against real behavior, not placeholders. The system test opens an actual headless Chrome browser, clicks the real upvote button, and checks that the count changes without a full page navigation happening.

## Deploying

The Dockerfile Rails 8 generates by default is here and builds a working production image (`docker build -t dad-jokes-rails .`). `config/deploy.yml` and `.kamal/` are set up for Kamal-based deployment if you want to push this to a server later. `.github/workflows/ci.yml` runs the test suite, a security scan (Brakeman), a dependency vulnerability scan, and RuboCop linting on every push and pull request.

## What's different from the original app

The original Express/React version had an admin-gated moderation queue: every submitted joke sat as "pending" until someone approved it. This rewrite skips that, a submitted joke goes live right away. Nothing in the original brief for this rewrite asked for an admin system or login, and adding one would mean inventing authentication out of nowhere, so submissions are validated (no empty or too-short jokes get through) but not queued for review.

The original app also had a category as a plain text field with a fixed list of allowed values. Here, categories are a real database table with their own model (`Category`), and each joke belongs to one. That's a more natural fit for how Rails works and makes the category filter and stats breakdown simpler to build correctly.

The database is SQLite instead of PostgreSQL, matching how the other Rails rewrites in this set of repos are set up: no separate database server to install, same relational features, everything just runs.
