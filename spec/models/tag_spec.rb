require "rails_helper"

RSpec.describe Tag, type: :model do
  fixtures :users, :tags

  describe "#names_matching_prefix" do
    let(:user) { users(:danliu) }
    before(:each) { @names = Tag.names_matching_prefix(name_prefix, user) }

    context "when some tags have name matching the prefix and owned by the user" do
      let(:name_prefix) { "@" }

      it "returns the tag names" do
        expect(@names).to contain_exactly("@countdown", "@newworld")
      end

      it "returns tag names in ascending alphabetic order" do
        expect(@names).to eql(["@countdown", "@newworld"])
      end
    end

    context "when some tags have name matching the prefix but none owned by the user" do
      let(:name_prefix) { "@" }
      let(:user) { users(:nobody) }

      it "returs nothing" do
        expect(@names).to be_empty
      end
    end

    context "when no tag has name matching the prefix" do
      let(:name_prefix) { "countdown" }

      it "returns nothing" do
        expect(@names).to be_empty
      end
    end
  end
end