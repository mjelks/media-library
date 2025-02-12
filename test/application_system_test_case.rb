require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  if ENV["CAPYBARA_SERVER_PORT"]
    served_by host: "rails-app", port: ENV["CAPYBARA_SERVER_PORT"]

    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ], options: {
      browser: :remote,
      url: "http://#{ENV["SELENIUM_HOST"]}:4444"
    }
  else
    driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]
  end

  def login_as(user)
    # Assuming you have a login path and a form with `email` and `password`
    visit new_session_url
    fill_in "email_address", with: user.email_address
    fill_in "password", with: "password"
    within("form") do
      # click_on "Sign in"
      click_button "commit"
    end
  end
end
