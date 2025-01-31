require "rails_helper"

RSpec.describe MediaTypesController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(get: "/media_types").to route_to("media_types#index")
    end

    it "routes to #new" do
      expect(get: "/media_types/new").to route_to("media_types#new")
    end

    it "routes to #show" do
      expect(get: "/media_types/1").to route_to("media_types#show", id: "1")
    end

    it "routes to #edit" do
      expect(get: "/media_types/1/edit").to route_to("media_types#edit", id: "1")
    end


    it "routes to #create" do
      expect(post: "/media_types").to route_to("media_types#create")
    end

    it "routes to #update via PUT" do
      expect(put: "/media_types/1").to route_to("media_types#update", id: "1")
    end

    it "routes to #update via PATCH" do
      expect(patch: "/media_types/1").to route_to("media_types#update", id: "1")
    end

    it "routes to #destroy" do
      expect(delete: "/media_types/1").to route_to("media_types#destroy", id: "1")
    end
  end
end
