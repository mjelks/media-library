require "test_helper"

class LpCartridgesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @cartridge = lp_cartridges(:current_cartridge)
  end

  test "should get index" do
    get lp_cartridges_url
    assert_response :success
  end

  test "should get new" do
    get new_lp_cartridge_url
    assert_response :success
  end

  test "should create lp_cartridge" do
    assert_difference("LpCartridge.count") do
      post lp_cartridges_url, params: {
        lp_cartridge: {
          name: "Ortofon 2M Red",
          installed_at: Date.today,
          usage_limit: 500,
          notes: "Entry level cartridge"
        }
      }
    end
    assert_redirected_to lp_cartridges_url
  end

  test "should not create lp_cartridge without name" do
    assert_no_difference("LpCartridge.count") do
      post lp_cartridges_url, params: {
        lp_cartridge: { installed_at: Date.today }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create lp_cartridge without installed_at" do
    assert_no_difference("LpCartridge.count") do
      post lp_cartridges_url, params: {
        lp_cartridge: { name: "Ortofon 2M Red" }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_lp_cartridge_url(@cartridge)
    assert_response :success
  end

  test "should update lp_cartridge name" do
    patch lp_cartridge_url(@cartridge), params: {
      lp_cartridge: { name: "Updated Cartridge Name" }
    }
    assert_redirected_to lp_cartridges_url
    assert_equal "Updated Cartridge Name", @cartridge.reload.name
  end

  test "should update lp_cartridge usage_limit" do
    patch lp_cartridge_url(@cartridge), params: {
      lp_cartridge: { usage_limit: 300 }
    }
    assert_redirected_to lp_cartridges_url
    assert_equal 300, @cartridge.reload.usage_limit
  end

  test "should not update lp_cartridge with blank name" do
    patch lp_cartridge_url(@cartridge), params: {
      lp_cartridge: { name: "" }
    }
    assert_response :unprocessable_entity
    assert_equal lp_cartridges(:current_cartridge).name, @cartridge.reload.name
  end

  test "should destroy lp_cartridge" do
    assert_difference("LpCartridge.count", -1) do
      delete lp_cartridge_url(@cartridge)
    end
    assert_redirected_to lp_cartridges_url
  end

  test "should require authentication" do
    delete session_path
    get lp_cartridges_url
    assert_redirected_to new_session_path
  end
end
