require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/media_types", type: :request do
  # This should return the minimal set of attributes required to create a valid
  # MediaType. As you add validations to MediaType, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    skip("Add a hash of attributes valid for your model")
  }

  let(:invalid_attributes) {
    skip("Add a hash of attributes invalid for your model")
  }

  describe "GET /index" do
    it "renders a successful response" do
      MediaType.create! valid_attributes
      get media_types_url
      expect(response).to be_successful
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      media_type = MediaType.create! valid_attributes
      get media_type_url(media_type)
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_media_type_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    it "renders a successful response" do
      media_type = MediaType.create! valid_attributes
      get edit_media_type_url(media_type)
      expect(response).to be_successful
    end
  end

  describe "POST /create" do
    context "with valid parameters" do
      it "creates a new MediaType" do
        expect {
          post media_types_url, params: { media_type: valid_attributes }
        }.to change(MediaType, :count).by(1)
      end

      it "redirects to the created media_type" do
        post media_types_url, params: { media_type: valid_attributes }
        expect(response).to redirect_to(media_type_url(MediaType.last))
      end
    end

    context "with invalid parameters" do
      it "does not create a new MediaType" do
        expect {
          post media_types_url, params: { media_type: invalid_attributes }
        }.to change(MediaType, :count).by(0)
      end

      it "renders a successful response (i.e. to display the 'new' template)" do
        post media_types_url, params: { media_type: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "PATCH /update" do
    context "with valid parameters" do
      let(:new_attributes) {
        skip("Add a hash of attributes valid for your model")
      }

      it "updates the requested media_type" do
        media_type = MediaType.create! valid_attributes
        patch media_type_url(media_type), params: { media_type: new_attributes }
        media_type.reload
        skip("Add assertions for updated state")
      end

      it "redirects to the media_type" do
        media_type = MediaType.create! valid_attributes
        patch media_type_url(media_type), params: { media_type: new_attributes }
        media_type.reload
        expect(response).to redirect_to(media_type_url(media_type))
      end
    end

    context "with invalid parameters" do
      it "renders a successful response (i.e. to display the 'edit' template)" do
        media_type = MediaType.create! valid_attributes
        patch media_type_url(media_type), params: { media_type: invalid_attributes }
        expect(response).to be_successful
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested media_type" do
      media_type = MediaType.create! valid_attributes
      expect {
        delete media_type_url(media_type)
      }.to change(MediaType, :count).by(-1)
    end

    it "redirects to the media_types list" do
      media_type = MediaType.create! valid_attributes
      delete media_type_url(media_type)
      expect(response).to redirect_to(media_types_url)
    end
  end
end
