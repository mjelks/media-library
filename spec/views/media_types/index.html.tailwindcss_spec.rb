require 'rails_helper'

RSpec.describe "media_types/index", type: :view do
  before(:each) do
    assign(:media_types, [
      MediaType.create!(
        name: "Name",
        description: "MyText"
      ),
      MediaType.create!(
        name: "Name",
        description: "MyText"
      )
    ])
  end

  it "renders a list of media_types" do
    render
    assert_select "tr>td", text: "Name".to_s, count: 2
    assert_select "tr>td", text: "MyText".to_s, count: 2
  end
end
