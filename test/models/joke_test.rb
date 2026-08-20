require "test_helper"

class JokeTest < ActiveSupport::TestCase
  # setup runs before every single test method below, gives each test a
  # fresh, valid starting point (an already-valid joke) to tweak and break in
  # whatever way that particular test needs.
  setup do
    @joke = jokes(:scarecrow)
  end

  test "a joke built from valid attributes saves successfully" do
    joke = Joke.new(setup: "Why did the bicycle fall over?", punchline: "It was two-tired.",
                     category: categories(:puns), groan_level: 6)
    assert joke.valid?
  end

  test "setup must be present" do
    @joke.setup = ""
    assert_not @joke.valid?
    assert_includes @joke.errors[:setup], "can't be blank"
  end

  test "setup must be at least 5 characters" do
    @joke.setup = "Hi!"
    assert_not @joke.valid?
  end

  test "punchline must be present" do
    @joke.punchline = ""
    assert_not @joke.valid?
    assert_includes @joke.errors[:punchline], "can't be blank"
  end

  test "punchline as short as 2 characters is still valid" do
    # The original app allowed very short real punchlines (like "Attire."),
    # this confirms the Rails version kept that same low minimum instead of
    # accidentally tightening it.
    @joke.punchline = "Hi"
    assert @joke.valid?
  end

  test "groan_level must be between 1 and 10" do
    @joke.groan_level = 0
    assert_not @joke.valid?
    @joke.groan_level = 11
    assert_not @joke.valid?
    @joke.groan_level = 10
    assert @joke.valid?
  end

  test "a joke requires a category" do
    @joke.category = nil
    assert_not @joke.valid?
  end

  test "score is upvotes minus downvotes" do
    @joke.upvotes = 12
    @joke.downvotes = 4
    assert_equal 8, @joke.score
  end

  test "controversial_score is 0 for a joke with no votes at all" do
    @joke.upvotes = 0
    @joke.downvotes = 0
    assert_equal 0.0, @joke.controversial_score
  end

  test "controversial_score is highest for a perfectly split vote" do
    @joke.upvotes = 10
    @joke.downvotes = 10
    assert_equal 0.5, @joke.controversial_score
  end

  test "controversial_score is low for a lopsided vote" do
    @joke.upvotes = 99
    @joke.downvotes = 1
    assert_in_delta 0.01, @joke.controversial_score, 0.001
  end

  test "sorted_by top_voted orders by net score descending" do
    top = Joke.create!(setup: "Top voted test joke", punchline: "Beats everyone.",
                        category: categories(:classic), groan_level: 5, upvotes: 100, downvotes: 0)
    bottom = Joke.create!(setup: "Bottom voted test joke", punchline: "Loses to everyone.",
                           category: categories(:classic), groan_level: 5, upvotes: 0, downvotes: 100)
    ordered = Joke.where(id: [top.id, bottom.id]).sorted_by(nil)
    assert_equal [top, bottom], ordered.to_a
  end

  test "sorted_by groan orders by groan_level descending" do
    mild = Joke.create!(setup: "Mild groan test joke", punchline: "Barely a chuckle.",
                         category: categories(:classic), groan_level: 1)
    intense = Joke.create!(setup: "Intense groan test joke", punchline: "Total collapse.",
                            category: categories(:classic), groan_level: 10)
    ordered = Joke.where(id: [mild.id, intense.id]).sorted_by("groan")
    assert_equal [intense, mild], ordered.to_a
  end

  test "sorted_by an unrecognized value falls back to top_voted" do
    assert_equal Joke.top_voted.to_a, Joke.sorted_by("nonsense").to_a
  end
end
