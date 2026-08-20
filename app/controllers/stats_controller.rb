# Powers the stats/analytics page, a read-only dashboard summarizing the
# whole joke collection: how many jokes, how many votes, the average groan
# level, the single most popular joke, and a per-category breakdown.
class StatsController < ApplicationController
  def index
    @total_jokes = Joke.count
    # Total votes cast is just every upvote plus every downvote added up
    # across the whole table, SQL's SUM does that in one query instead of
    # loading every joke into Ruby to add the numbers up by hand.
    @total_votes = Joke.sum(:upvotes) + Joke.sum(:downvotes)
    # average returns nil if there are zero jokes (avoids a divide-by-zero
    # crash on a totally empty database), so we fall back to 0 in that case.
    @avg_groan_level = Joke.average(:groan_level)&.round(1) || 0
    # The single joke with the highest upvote count, or nil if there are no
    # jokes yet at all.
    @most_upvoted = Joke.order(upvotes: :desc).first
    # How many jokes live in each category, sorted from most jokes to fewest,
    # this is what draws the bar-chart-style breakdown on the page.
    @category_counts = Category.alphabetical.left_joins(:jokes)
                                .group(:name).count(:"jokes.id")
                                .sort_by { |_name, count| -count }
  end
end
