require 'rails_helper'

RSpec.describe "media_types/show", type: :view do
  before(:each) do
    @media_type = assign(:media_type, MediaType.create!(
      name: "Name",
      description: "MyText"
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/Name/)
    expect(rendered).to match(/MyText/)
  end
end
