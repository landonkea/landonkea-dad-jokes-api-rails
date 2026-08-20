require "test_helper"

class StatsControllerTest < ActionDispatch::IntegrationTest
  test "stats page renders successfully with the right totals" do
    get stats_url
    assert_response :success
    assert_select "body", /#{Joke.count} .*Total Jokes/m
  end

  test "stats page highlights the most upvoted joke" do
    get stats_url
    assert_response :success
    top = Joke.order(upvotes: :desc).first
    assert_select "body", /#{Regexp.escape(top.setup)}/
  end
end
