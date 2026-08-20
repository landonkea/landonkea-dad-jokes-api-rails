# Handles everything about browsing, viewing, and submitting jokes. Voting
# lives in its own controller (VotesController) because it's a different
# resource with a different job.
class JokesController < ApplicationController
  # How many jokes to show per page on the browse listing. A constant here
  # means the pagination math below and the view's page-link math both read
  # from the same single number instead of a magic 10 copy-pasted in two places.
  PER_PAGE = 10

  # GET /jokes - the "Browse Jokes" page. Supports filtering by category and
  # choosing a sort order, both via query-string params, e.g.
  # /jokes?category=puns&sort=groan&page=2
  def index
    # includes(:category) avoids the "N+1 query" problem, without it, showing
    # 10 jokes' category names would fire 10 extra database queries, one per
    # joke, instead of the category data coming back with the original query.
    jokes = Joke.includes(:category)

    # Only filter by category if the visitor actually picked one, an empty or
    # missing param means "show every category."
    if params[:category].present?
      jokes = jokes.joins(:category).where(categories: { name: params[:category] })
    end

    # Delegate the actual ORDER BY choice to the model, keeps the "what does
    # 'sort=groan' mean" knowledge in one place (Joke.sorted_by) instead of
    # duplicated in every controller action that might need sorting.
    jokes = jokes.sorted_by(params[:sort])

    # Simple page-number pagination without a gem: figure out which page
    # we're on (defaulting to 1, and never less than 1 even if someone hand-edits
    # the URL to page=0 or page=-5), then ask the database for just that slice.
    @page = [params[:page].to_i, 1].max
    @total_count = jokes.count
    @total_pages = [(@total_count.to_f / PER_PAGE).ceil, 1].max
    @jokes = jokes.limit(PER_PAGE).offset((@page - 1) * PER_PAGE)

    # The category filter buttons need every category plus how many jokes
    # are in each one, so the browse page can show "puns (6)" the way the
    # original app's CategoryPicker did.
    @categories = Category.alphabetical.left_joins(:jokes).group(:id).count(:"jokes.id")
    # Which category (if any) is currently selected, so the view can
    # highlight the active filter button.
    @selected_category = params[:category]
    # Which sort is currently selected, same idea, for the sort dropdown.
    @selected_sort = params[:sort]
  end

  # GET /jokes/:id - a single joke's own page (mostly reached by clicking a
  # joke's setup line from the browse list, works like a permalink).
  def show
    @joke = Joke.includes(:category).find(params[:id])
    # Figure out up front whether this visitor has already voted on this
    # joke, so the view can gray out the vote buttons instead of letting
    # someone click a vote that the server will just reject anyway.
    @already_voted = Vote.exists?(joke: @joke, voter_ip: request.remote_ip)
  end

  # GET /random and GET / (the homepage) - picks one joke completely at
  # random. This is the "roll the dice" experience the original app opened
  # to by default.
  def random
    # ORDER BY RANDOM() shuffles every row and LIMIT 1 takes the first one,
    # simple and fine for a joke table that's never going to have millions
    # of rows.
    @joke = Joke.order(Arel.sql("RANDOM()")).first
    @already_voted = @joke && Vote.exists?(joke: @joke, voter_ip: request.remote_ip)
    # Render the same view whichever route got us here (root "/" or "/random"),
    # so there's only one template to keep in sync.
    render :random
  end

  # GET /jokes/new - the "Submit Your Dad Joke" form.
  def new
    @joke = Joke.new
    @categories = Category.alphabetical
  end

  # POST /jokes - saves a new joke submitted through the form above.
  def create
    @joke = Joke.new(joke_params)
    if @joke.save
      # A friendly flash message, then straight to the new joke's own page so
      # the submitter can see exactly what they just added.
      redirect_to @joke, notice: "Joke submitted! It's live and ready to be groaned at."
    else
      # Validation failed (e.g. punchline too short), re-render the same form
      # with the entered values still filled in and Rails' error messages
      # attached, so the visitor doesn't have to retype everything.
      @categories = Category.alphabetical
      render :new, status: :unprocessable_content
    end
  end

  private

  # Only pull out the specific fields we expect from the submission form.
  # This is "strong parameters", Rails' built-in defense against a visitor
  # sneaking extra fields (like upvotes=99999) into the submitted form data.
  def joke_params
    params.expect(joke: [:setup, :punchline, :category_id, :groan_level, :author])
  end
end
