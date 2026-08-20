# Handles casting a vote on a joke. This is deliberately its own tiny
# controller (rather than an action tucked inside JokesController) because
# voting is really a different resource: you're creating a Vote record, not
# changing a Joke directly.
class VotesController < ApplicationController
  # POST /jokes/:joke_id/vote - records an upvote or downvote and bumps the
  # joke's counter. Responds with a Turbo Stream so the vote count updates on
  # the page instantly, without a full browser reload, that's the "voting
  # without full page reloads" behavior Turbo gives us for free.
  def create
    @joke = Joke.find(params[:joke_id])
    # Build (but don't save yet) a vote tied to this joke, whoever's making
    # the request, and whichever button they clicked ("up" or "down").
    # request.remote_ip is the closest thing this app has to "who are you",
    # there's no login system, so an IP address is the whole identity story.
    @vote = @joke.votes.build(vote_type: params[:vote_type], voter_ip: request.remote_ip)

    if @vote.save
      # Bump whichever counter this vote was for. "increment!" both changes
      # the number in memory and immediately saves it to the database in one step.
      @joke.increment!(@vote.vote_type == "up" ? :upvotes : :downvotes)
      @already_voted = true
    else
      # Saving failed, almost always because this voter_ip already has a vote
      # on this joke (see the uniqueness validation on Vote). We don't treat
      # this as a hard error, the visitor just gets to see "you already voted"
      # instead of the buttons re-enabling.
      @already_voted = true
    end

    respond_to do |format|
      # A JavaScript-capable browser using Turbo gets just the small sliver of
      # HTML that needs to change (the vote button/count partial), Turbo
      # swaps it into the page in place.
      format.turbo_stream
      # Anyone without JavaScript (or a bot, or a curl request) still gets a
      # working experience: a normal redirect back to wherever they voted from.
      format.html { redirect_back fallback_location: root_path }
    end
  end
end
