# This file fills a fresh database with starter data so the app isn't an
# empty, boring page the first time you run it. "rails db:seed" runs this
# file. It's also run automatically by db:setup and by the test suite's
# fixtures are separate, so this only affects your real development database.

# Every category the joke dropdown offers, pulled from the same list the Joke
# model exposes (Joke::CATEGORY_NAMES), so this file and the model can never
# drift out of sync with each other.
Joke::CATEGORY_NAMES.each do |name|
  # find_or_create_by! means "if a category with this name already exists,
  # reuse it, otherwise make a new one." That's what makes this file safe to
  # run more than once without creating duplicate categories.
  Category.find_or_create_by!(name: name)
end

# A grab bag of real dad jokes, ported over from the original Express app's
# seed data (server/src/db/seed.ts) so this Rails version starts out with the
# same jokes instead of an empty table. Each entry is a small hash of the
# fields a Joke needs.
seed_jokes = [
  { setup: "I'm afraid for the calendar.", punchline: "Its days are numbered.", category: "puns", groan_level: 8, author: "Dad #1" },
  { setup: "What do you call a fake noodle?", punchline: "An impasta.", category: "puns", groan_level: 9, author: "Dad #2" },
  { setup: "Why don't scientists trust atoms?", punchline: "They make up everything.", category: "science", groan_level: 7, author: "Dad #3" },
  { setup: "I told my wife she was drawing her eyebrows too high.", punchline: "She looked surprised.", category: "classic", groan_level: 10, author: "Dad #4" },
  { setup: "What do you call a dog that does magic?", punchline: "A Labracadabrador.", category: "animals", groan_level: 9, author: "Dad #5" },
  { setup: "I used to hate facial hair.", punchline: "But then it grew on me.", category: "classic", groan_level: 8, author: "Dad #6" },
  { setup: "What do you call a bear with no teeth?", punchline: "A gummy bear.", category: "animals", groan_level: 7, author: "Dad #7" },
  { setup: "Why did the scarecrow win an award?", punchline: "He was outstanding in his field.", category: "classic", groan_level: 10, author: "Dad #8" },
  { setup: "What do you call a bear in the rain?", punchline: "A drizzly bear.", category: "animals", groan_level: 8, author: "Dad #9" },
  { setup: "I'm reading a book about anti-gravity.", punchline: "It's impossible to put down.", category: "science", groan_level: 9, author: "Dad #10" },
  { setup: "What did the ocean say to the beach?", punchline: "Nothing, it just waved.", category: "classic", groan_level: 10, author: "Dad #11" },
  { setup: "Why don't eggs tell jokes?", punchline: "They'd crack each other up.", category: "food", groan_level: 7, author: "Dad #12" },
  { setup: "I'm on a seafood diet.", punchline: "I see food and I eat it.", category: "food", groan_level: 9, author: "Dad #13" },
  { setup: "What do you call cheese that isn't yours?", punchline: "Nacho cheese.", category: "food", groan_level: 10, author: "Dad #14" },
  { setup: "I got fired from the calendar factory.", punchline: "All I did was take a day off.", category: "classic", groan_level: 8, author: "Dad #15" },
  { setup: "What's orange and sounds like a parrot?", punchline: "A carrot.", category: "food", groan_level: 7, author: "Dad #16" },
  { setup: "I have a joke about trickle-down economics.", punchline: "But 99% of you won't get it.", category: "smart", groan_level: 10, author: "Dad #17" },
  { setup: "What do you call a sleeping dinosaur?", punchline: "A dino-snore.", category: "animals", groan_level: 8, author: "Dad #18" },
  { setup: "I'm terrified of elevators.", punchline: "I'm going to start taking steps to avoid them.", category: "classic", groan_level: 9, author: "Dad #19" },
  { setup: "What do you call a cold dog sitting on a rabbit?", punchline: "A chili dog on a bunny.", category: "animals", groan_level: 10, author: "Dad #20" },
  { setup: "Parallel lines have so much in common.", punchline: "It's a shame they'll never meet.", category: "math", groan_level: 10, author: "Dad #21" },
  { setup: "My boss told me to have a good day.", punchline: "So I went home.", category: "work", groan_level: 9, author: "Dad #22" },
  { setup: "What's the best thing about Switzerland?", punchline: "I don't know, but the flag is a big plus.", category: "geography", groan_level: 10, author: "Dad #23" },
  { setup: "I invented a new word.", punchline: "Plagiarism.", category: "smart", groan_level: 10, author: "Dad #24" },
  { setup: "What do you call a group of 8 hobbits?", punchline: "A hobbyte.", category: "smart", groan_level: 8, author: "Dad #25" },
  { setup: "I asked the librarian if the library had any books about paranoia.", punchline: "She whispered, 'They're right behind you!'", category: "classic", groan_level: 9, author: "Dad #26" },
  { setup: "What's the difference between a well-dressed man on a bike and a poorly dressed man on a unicycle?", punchline: "Attire.", category: "smart", groan_level: 10, author: "Dad #27" },
  { setup: "I told a chemistry joke.", punchline: "There was no reaction.", category: "science", groan_level: 8, author: "Dad #28" },
  { setup: "What do you call a dinosaur that crashes their car?", punchline: "Tyrannosaurus Wrecks.", category: "animals", groan_level: 9, author: "Dad #29" },
  { setup: "I told my kids a joke about a broken pencil.", punchline: "Never mind, it's pointless.", category: "classic", groan_level: 10, author: "Dad #30" },
]

# Only seed jokes if the table is completely empty. Without this guard,
# running "rails db:seed" a second time would insert 30 more duplicate jokes.
if Joke.count.zero?
  seed_jokes.each do |joke_data|
    # Look up the Category row that matches this joke's category name, we
    # need the actual row (not just the string) because Joke belongs_to :category.
    category = Category.find_by!(name: joke_data[:category])
    # A random number of upvotes between 0 and 199, and downvotes between 0
    # and 29 (a smaller range so jokes generally look net-positive), purely
    # so the seeded jokes look like a real, lived-in dataset instead of
    # thirty identical zeroes.
    Joke.create!(
      setup: joke_data[:setup],
      punchline: joke_data[:punchline],
      category: category,
      groan_level: joke_data[:groan_level],
      author: joke_data[:author],
      upvotes: rand(0..199),
      downvotes: rand(0..29)
    )
  end
  puts "Seeded #{seed_jokes.length} jokes across #{Category.count} categories."
else
  puts "Jokes already exist (#{Joke.count} of them), skipping seed data."
end
