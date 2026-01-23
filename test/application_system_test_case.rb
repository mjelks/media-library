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
    # Wait for the modal to be visible and form to be ready
    assert_selector "#modal", visible: true
    assert_selector "#modal input[name='email_address']", visible: true
    assert_selector "#modal input[name='password']", visible: true
    assert_button "Sign in", disabled: false

    within("#modal") do
      fill_in "email_address", with: user.email_address
      fill_in "password", with: "password"
      click_button "Sign in"
    end
  end
end
