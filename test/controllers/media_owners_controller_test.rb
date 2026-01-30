require "test_helper"

class MediaOwnersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @media_owner = media_owners(:one)
  end

  test "should get index" do
    get media_owners_url
    assert_response :success
  end

  test "should order by name case-insensitive" do
    MediaOwner.create!(name: "zebra", description: "Last alphabetically")
    MediaOwner.create!(name: "Apple", description: "First alphabetically")
    get media_owners_url
    assert_response :success
  end

  test "should get show" do
    get media_owner_url(@media_owner)
    assert_response :success
  end

  test "should get new" do
    get new_media_owner_url
    assert_response :success
  end

  test "should create media_owner" do
    assert_difference("MediaOwner.count") do
      post media_owners_url, params: {
        media_owner: {
          name: "New Artist",
          description: "A new musical artist"
        }
      }
    end
    assert_redirected_to media_owner_url(MediaOwner.last)
  end

  test "should create media_owner with json format" do
    assert_difference("MediaOwner.count") do
      post media_owners_url, params: {
        media_owner: {
          name: "JSON Artist",
          description: "Created via JSON"
        }
      }, as: :json
    end
    assert_response :created
  end

  test "should not create media_owner with invalid data" do
    assert_no_difference("MediaOwner.count") do
      post media_owners_url, params: {
        media_owner: {
          name: "",
          description: "No name provided"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create media_owner with json format when invalid" do
    assert_no_difference("MediaOwner.count") do
      post media_owners_url, params: {
        media_owner: {
          name: "",
          description: "No name provided"
        }
      }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_media_owner_url(@media_owner)
    assert_response :success
  end

  test "should update media_owner" do
    patch media_owner_url(@media_owner), params: {
      media_owner: {
        name: "Updated Artist Name",
        description: "Updated description"
      }
    }
    assert_redirected_to media_owner_url(@media_owner)
    @media_owner.reload
    assert_equal "Updated Artist Name", @media_owner.name
  end

  test "should update media_owner with json format" do
    patch media_owner_url(@media_owner), params: {
      media_owner: {
        name: "JSON Updated Artist"
      }
    }, as: :json
    assert_response :ok
  end

  test "should not update media_owner with invalid data" do
    patch media_owner_url(@media_owner), params: {
      media_owner: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "should not update media_owner with json format when invalid" do
    patch media_owner_url(@media_owner), params: {
      media_owner: {
        name: ""
      }
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "should destroy media_owner" do
    media_owner_to_delete = MediaOwner.create!(name: "ToDelete", description: "Will be deleted")
    assert_difference("MediaOwner.count", -1) do
      delete media_owner_url(media_owner_to_delete)
    end
    assert_redirected_to media_owners_url
  end

  test "should destroy media_owner with json format" do
    media_owner_to_delete = MediaOwner.create!(name: "ToDeleteJSON", description: "Will be deleted via JSON")
    assert_difference("MediaOwner.count", -1) do
      delete media_owner_url(media_owner_to_delete), as: :json
    end
    assert_response :no_content
  end

  test "should require authentication" do
    delete session_path
    get media_owners_url
    assert_redirected_to new_session_path
  end
end
