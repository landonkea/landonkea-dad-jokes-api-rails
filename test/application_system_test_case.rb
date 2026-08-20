require "test_helper"

# The shared base class every system test inherits from. System tests are
# different from regular controller tests, they drive an actual (headless)
# browser through the real pages, clicking buttons and reading the resulting
# HTML, the closest thing to a real person using the site.
class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  # "headless_chrome" runs a real Chrome browser with no visible window,
  # exactly what Chrome renders for a real visitor, just without a screen to
  # show it on (useful for CI, where nothing is watching).
  driven_by :selenium, using: :headless_chrome, screen_size: [1400, 1400]
end
