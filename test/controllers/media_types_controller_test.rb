require "test_helper"

class MediaTypesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:default_user)
    login_as(@user)
    @media_type = media_types(:one)
  end

  test "should get index" do
    get media_types_url
    assert_response :success
  end

  test "should get show" do
    get media_type_url(@media_type)
    assert_response :success
  end

  test "should get new" do
    get new_media_type_url
    assert_response :success
  end

  test "should create media_type" do
    assert_difference("MediaType.count") do
      post media_types_url, params: {
        media_type: {
          name: "Cassette",
          description: "Magnetic tape format"
        }
      }
    end
    assert_redirected_to media_type_url(MediaType.last)
  end

  test "should create media_type with json format" do
    assert_difference("MediaType.count") do
      post media_types_url, params: {
        media_type: {
          name: "8-Track",
          description: "8-track tape cartridge"
        }
      }, as: :json
    end
    assert_response :created
  end

  test "should not create media_type with invalid data" do
    assert_no_difference("MediaType.count") do
      post media_types_url, params: {
        media_type: {
          name: "",
          description: "No name provided"
        }
      }
    end
    assert_response :unprocessable_entity
  end

  test "should not create media_type with json format when invalid" do
    assert_no_difference("MediaType.count") do
      post media_types_url, params: {
        media_type: {
          name: "",
          description: "No name provided"
        }
      }, as: :json
    end
    assert_response :unprocessable_entity
  end

  test "should get edit" do
    get edit_media_type_url(@media_type)
    assert_response :success
  end

  test "should update media_type" do
    patch media_type_url(@media_type), params: {
      media_type: {
        name: "Updated Album",
        description: "Updated description"
      }
    }
    assert_redirected_to media_type_url(@media_type)
    @media_type.reload
    assert_equal "Updated Album", @media_type.name
  end

  test "should update media_type with json format" do
    patch media_type_url(@media_type), params: {
      media_type: {
        name: "Updated Album JSON"
      }
    }, as: :json
    assert_response :ok
  end

  test "should not update media_type with invalid data" do
    patch media_type_url(@media_type), params: {
      media_type: {
        name: ""
      }
    }
    assert_response :unprocessable_entity
  end

  test "should not update media_type with json format when invalid" do
    patch media_type_url(@media_type), params: {
      media_type: {
        name: ""
      }
    }, as: :json
    assert_response :unprocessable_entity
  end

  test "should destroy media_type" do
    media_type_to_delete = MediaType.create!(name: "ToDelete", description: "Will be deleted")
    assert_difference("MediaType.count", -1) do
      delete media_type_url(media_type_to_delete)
    end
    assert_redirected_to media_types_url
  end

  test "should destroy media_type with json format" do
    media_type_to_delete = MediaType.create!(name: "ToDeleteJSON", description: "Will be deleted via JSON")
    assert_difference("MediaType.count", -1) do
      delete media_type_url(media_type_to_delete), as: :json
    end
    assert_response :no_content
  end

  test "should require authentication" do
    delete session_path
    get media_types_url
    assert_redirected_to new_session_path
  end
end
