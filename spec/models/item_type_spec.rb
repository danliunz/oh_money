require "rails_helper"

RSpec.describe ItemType, type: :model do
  fixtures :users, :item_types

  describe "#names_matching_prefix" do
    context "when some item type's name matches the prefix and owned by specified user" do
      let(:prefix) { "beer" }
      let(:user) { users(:danliu) }

      it "returns the matching type names" do
        names = ItemType.names_matching_prefix(prefix, user)
        expect(names).to contain_exactly("beer")
      end
    end

    context "when some item type's name matches the prefix but none is owned by specified user" do
      let(:prefix) { "beer" }
      let(:user) { users(:nobody) }

      it "returns empty" do
        names = ItemType.names_matching_prefix(prefix, user)
        expect(names).to be_empty
      end
    end

    context "when no item type's name matches the prefix" do
      let(:prefix) { "block hole" }
      let(:user) { users(:nobody) }

      it "returns empty" do
        names = ItemType.names_matching_prefix(prefix, user)
        expect(names).to be_empty
      end
    end
  end
end
