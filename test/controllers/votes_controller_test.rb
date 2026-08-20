require "test_helper"

class VotesControllerTest < ActionDispatch::IntegrationTest
  test "an upvote increases the joke's upvotes count" do
    joke = jokes(:impasta)
    assert_difference("joke.reload.upvotes", 1) do
      post joke_vote_url(joke), params: { vote_type: "up" }
    end
  end

  test "a downvote increases the joke's downvotes count" do
    joke = jokes(:impasta)
    assert_difference("joke.reload.downvotes", 1) do
      post joke_vote_url(joke), params: { vote_type: "down" }
    end
  end

  test "voting creates a Vote record tied to the requester's IP" do
    joke = jokes(:impasta)
    assert_difference("Vote.count", 1) do
      post joke_vote_url(joke), params: { vote_type: "up" }
    end
    assert Vote.exists?(joke: joke, vote_type: "up")
  end

  test "a second vote from the same IP on the same joke doesn't double-count" do
    joke = jokes(:impasta)
    post joke_vote_url(joke), params: { vote_type: "up" }
    assert_no_difference("Vote.count") do
      post joke_vote_url(joke), params: { vote_type: "up" }
    end
    assert_equal 1, joke.reload.upvotes
  end

  test "voting via Turbo Stream responds with the updated vote partial" do
    joke = jokes(:impasta)
    post joke_vote_url(joke), params: { vote_type: "up" }, as: :turbo_stream
    assert_response :success
    assert_match "turbo-stream", response.media_type
    assert_match "#{joke.reload.upvotes}", response.body
  end

  test "voting without JavaScript (plain HTML) redirects back" do
    joke = jokes(:impasta)
    post joke_vote_url(joke), params: { vote_type: "up" }, headers: { "Referer" => joke_url(joke) }
    assert_redirected_to joke_url(joke)
  end
end
