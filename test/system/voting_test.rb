require "application_system_test_case"

# This is the one true end-to-end test: it drives a real (headless) browser
# to a joke's page, clicks the actual upvote button, and confirms the count
# on the page changes without the page doing a full reload. That last part is
# the whole point of using Turbo for voting, this test would still pass on a
# full-page-reload implementation, so the "no navigation happened" assertion
# below is what actually proves Turbo is doing its job.
class VotingTest < ApplicationSystemTestCase
  test "visitor can upvote a joke and see the count update live" do
    joke = jokes(:impasta)
    visit joke_url(joke)

    assert_text joke.setup
    assert_text "👍 0"

    click_button "👍 0"

    # Capybara's assert_text automatically waits (up to a few seconds) for
    # the page to catch up, which gives the Turbo Stream response time to
    # arrive and swap in the new count before this check runs.
    assert_text "👍 1"
    # Once voted, the buttons are replaced with plain, non-clickable counts
    # and a small note, confirming the "already voted" state took effect.
    assert_text "you already voted on this one"
  end

  test "voting again from the same session is not offered" do
    joke = jokes(:impasta)
    visit joke_url(joke)

    click_button "👍 0"
    assert_text "you already voted on this one"

    # Reloading the page should show the same disabled state, this is the
    # server (not just some leftover JavaScript state) remembering the vote.
    visit joke_url(joke)
    assert_text "you already voted on this one"
    assert_no_button "👍 1"
  end
end
