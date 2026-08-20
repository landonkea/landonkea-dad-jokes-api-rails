require "test_helper"

class JokesControllerTest < ActionDispatch::IntegrationTest
  test "index shows a successful page with the seeded jokes" do
    get jokes_url
    assert_response :success
    assert_select "body", /#{jokes(:scarecrow).setup}/
  end

  test "index filters by category" do
    get jokes_url(category: "puns")
    assert_response :success
    assert_select "body", /#{jokes(:impasta).setup}/
    assert_select "body", { text: /#{jokes(:scarecrow).setup}/, count: 0 }
  end

  test "index paginates so only PER_PAGE jokes show on one page" do
    # Push the total well past one page's worth so pagination actually kicks in.
    15.times do |i|
      Joke.create!(setup: "Pagination test joke number #{i}", punchline: "Punchline #{i}.",
                   category: categories(:classic), groan_level: 5)
    end
    get jokes_url
    assert_response :success
    assert_select ".space-y-4 > div", count: JokesController::PER_PAGE
  end

  test "show displays a single joke" do
    get joke_url(jokes(:scarecrow))
    assert_response :success
    assert_select "body", /#{jokes(:scarecrow).punchline}/
  end

  test "show responds 404 for a joke id that doesn't exist" do
    # Rails' test environment renders the real error page for a rescuable
    # exception like RecordNotFound (config.action_dispatch.show_exceptions
    # = :rescuable in config/environments/test.rb) rather than letting the
    # exception bubble up to the test itself, so we check the response status.
    get joke_url(id: 999_999)
    assert_response :not_found
  end

  test "random always returns some joke successfully" do
    get random_url
    assert_response :success
  end

  test "root path also renders a random joke" do
    get root_url
    assert_response :success
  end

  test "new renders the submission form" do
    get new_joke_url
    assert_response :success
    assert_select "form"
  end

  test "create saves a valid joke and redirects to it" do
    assert_difference("Joke.count", 1) do
      post jokes_url, params: { joke: {
        setup: "Why did the golfer bring two pairs of pants?",
        punchline: "In case he got a hole in one.",
        category_id: categories(:puns).id,
        groan_level: 7,
        author: "Test Dad"
      } }
    end
    assert_redirected_to joke_url(Joke.last)
  end

  test "create rejects an invalid joke and re-renders the form" do
    assert_no_difference("Joke.count") do
      post jokes_url, params: { joke: {
        setup: "Hi",
        punchline: "",
        category_id: categories(:puns).id,
        groan_level: 7
      } }
    end
    assert_response :unprocessable_content
    assert_select "form"
  end
end
