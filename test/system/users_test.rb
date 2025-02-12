require "application_system_test_case"
require "test_helper"

class UsersTest < ApplicationSystemTestCase
  fixtures :users

  setup do
    @user = users(:default_user)
  end

  test "visiting the index" do
    visit users_url
    # default behavior is to redirect to the page after logging in
    login_as(@user)
    assert_selector "h1", text: "Users"
  end

  test "should create user" do
    visit users_url
    login_as(@user)

    click_on "New user"
    fill_in "Email address", with: "foo@example.com"
    find("input[name='user[password_digest]']").set("mysecretpassword")

    click_on "Create User"
    assert_text "User was successfully created"
  end

  test "should update User" do
    visit user_url(@user)
    login_as(@user)

    click_on "Edit this user", match: :first
    find("input[name='user[password_digest]']").set("mysecretpassword-deux")
    click_on "Update User"

    assert_text "User was successfully updated"
  end

  test "should destroy User" do
    visit user_url(@user)
    login_as(@user)
    click_on "Destroy this user", match: :first

    assert_text "User was successfully destroyed"
  end
end
