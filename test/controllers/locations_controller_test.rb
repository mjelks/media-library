require "test_helper"

class LocationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @location = locations(:one)
    @media_type = media_types(:one)
  end

  test "should get index" do
    get locations_url
    assert_response :success
  end

  test "should get show" do
    get location_url(@location)
    assert_response :success
  end

  test "should get new" do
    get new_location_url
    assert_response :success
  end

  test "should create location" do
    assert_difference("Location.count") do
      post locations_url, params: {
        location: {
          name: "New Shelf",
          description: "A new storage location",
          media_type_id: @media_type.id,
          cube_location: "A",
          position: 1
        }
      }
    end
    assert_redirected_to location_url(Location.last)
  end

  test "should create location with json format" do
    assert_difference("Location.count") do
      post locations_url, params: {
        location: {
          name: "JSON Shelf",
          description: "Created via JSON",
          media_type_id: @media_type.id
        }
      }, as: :json
    end
    assert_response :created
  end

  test "should not create location without name" do
    assert_no_difference("Location.count") do
      post locations_url, params: {
        location: {
          name: "",
          description: "No name"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create location with json format when invalid" do
    assert_no_difference("Location.count") do
      post locations_url, params: {
        location: {
          name: "",
          description: "No name"
        }
      }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_location_url(@location)
    assert_response :success
  end

  test "should update location" do
    patch location_url(@location), params: {
      location: {
        name: "Updated Shelf Name",
        description: "Updated description"
      }
    }
    assert_redirected_to location_url(@location)
    @location.reload
    assert_equal "Updated Shelf Name", @location.name
  end

  test "should update location with json format" do
    patch location_url(@location), params: {
      location: {
        name: "JSON Updated Shelf"
      }
    }, as: :json
    assert_response :ok
  end

  test "should not update location with invalid data" do
    patch location_url(@location), params: {
      location: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "should not update location with json format when invalid" do
    patch location_url(@location), params: {
      location: {
        name: ""
      }
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "should destroy location" do
    location_to_delete = Location.create!(name: "ToDelete", description: "Will be deleted")
    assert_difference("Location.count", -1) do
      delete location_url(location_to_delete)
    end
    assert_redirected_to locations_url
  end

  test "should destroy location with json format" do
    location_to_delete = Location.create!(name: "ToDeleteJSON", description: "Delete via JSON")
    assert_difference("Location.count", -1) do
      delete location_url(location_to_delete), as: :json
    end
    assert_response :no_content
  end

  test "should require authentication" do
    delete session_path
    get locations_url
    assert_redirected_to new_session_path
  end
end
