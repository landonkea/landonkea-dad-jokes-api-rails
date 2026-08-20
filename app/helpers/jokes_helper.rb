# View helper methods used by the joke-related pages. Pulling this logic out
# of the view templates keeps the .erb files focused on markup instead of
# mixing in chunks of Ruby decision-making.
module JokesHelper
  # A bucket of funny reaction lines per groan-level range, ported from the
  # original React app's JokeCard component so revealing a punchline still
  # gets a matching reaction. Frozen so nothing accidentally mutates this
  # shared constant at runtime.
  GROAN_REACTIONS = {
    (9..10) => ["💀 That joke just ended me.", "🫠 I'm liquefied from that groan.", "⚰️ Call a priest, that joke was demonic."],
    (7..8) => ["😤 My neighbors heard that groan.", "🙄 I rolled my eyes so hard they did a 360.", "🫡 Respect. That was painfully good."],
    (5..6) => ["😐 A solid 'dad nod' of approval.", "😤 A respectable groan. Father would be proud.", "🫢 I smiled. Don't tell anyone."],
    (1..4) => ["😂 Wait... that was actually funny?", "🤨 Are you sure you're a dad?", "✨ A rare gem in a sea of groans."]
  }.freeze

  # Picks one random reaction string matching the given groan level. Used
  # right after a punchline is revealed, so the joke lands with a little bit
  # of extra flavor text instead of just sitting there silently.
  def groan_reaction_for(level)
    range, texts = GROAN_REACTIONS.find { |r, _| r.cover?(level) }
    # Fall back to the mildest bucket if somehow the level is outside 1-10
    # (shouldn't happen thanks to the model validation, but better a mild
    # reaction than a crashed page).
    (texts || GROAN_REACTIONS[(1..4)]).sample
  end

  # Turns a groan level number into that many repeated "tired face" emoji, a
  # quick visual gauge next to the numeric "7/10" score.
  def groan_meter(level)
    "😫" * level
  end
end
