require "test_helper"

class VoteTest < ActiveSupport::TestCase
  setup do
    @joke = jokes(:impasta)
  end

  test "a vote built from valid attributes saves successfully" do
    vote = Vote.new(joke: @joke, vote_type: "up", voter_ip: "198.51.100.7")
    assert vote.valid?
  end

  test "vote_type must be up or down, nothing else" do
    vote = Vote.new(joke: @joke, vote_type: "sideways", voter_ip: "198.51.100.7")
    assert_not vote.valid?
    assert_includes vote.errors[:vote_type], "is not included in the list"
  end

  test "voter_ip must be present" do
    vote = Vote.new(joke: @joke, vote_type: "up", voter_ip: "")
    assert_not vote.valid?
  end

  test "the same voter_ip can't vote on the same joke twice" do
    # votes(:already_voted) is fixture data: 203.0.113.5 already voted "up"
    # on the "scarecrow" joke, so a second vote from that same IP on that
    # same joke should be rejected.
    duplicate = Vote.new(joke: jokes(:scarecrow), vote_type: "down", voter_ip: "203.0.113.5")
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:voter_ip], "has already voted on this joke"
  end

  test "the same voter_ip CAN vote on a different joke" do
    vote = Vote.new(joke: @joke, vote_type: "down", voter_ip: "203.0.113.5")
    assert vote.valid?
  end

  test "different voter_ips can both vote on the same joke" do
    vote = Vote.new(joke: jokes(:scarecrow), vote_type: "down", voter_ip: "203.0.113.9")
    assert vote.valid?
  end
end
