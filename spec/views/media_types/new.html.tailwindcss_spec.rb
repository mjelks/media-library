require 'rails_helper'

RSpec.describe "media_types/new", type: :view do
  before(:each) do
    assign(:media_type, MediaType.new(
      name: "MyString",
      description: "MyText"
    ))
  end

  it "renders new media_type form" do
    render

    assert_select "form[action=?][method=?]", media_types_path, "post" do
      assert_select "input[name=?]", "media_type[name]"

      assert_select "textarea[name=?]", "media_type[description]"
    end
  end
end
