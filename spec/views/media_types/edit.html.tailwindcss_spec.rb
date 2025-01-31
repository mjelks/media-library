require 'rails_helper'

RSpec.describe "media_types/edit", type: :view do
  before(:each) do
    @media_type = assign(:media_type, MediaType.create!(
      name: "MyString",
      description: "MyText"
    ))
  end

  it "renders the edit media_type form" do
    render

    assert_select "form[action=?][method=?]", media_type_path(@media_type), "post" do

      assert_select "input[name=?]", "media_type[name]"

      assert_select "textarea[name=?]", "media_type[description]"
    end
  end
end
