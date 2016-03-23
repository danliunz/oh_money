require "rails_helper"

RSpec.describe ItemType, type: :model do
  fixtures :users, :item_types, :item_type_relations

  describe "::names_matching_prefix" do
    before(:each) { @names = ItemType.names_matching_prefix(prefix, user) }

    context "when some item type's name matches the prefix and owned by specified user" do
      let(:prefix) { "beer" }
      let(:user) { users(:danliu) }

      it "returns the matching type names" do
        expect(@names).to contain_exactly("beer", "beer pong")
      end

      it "returns the names in ascending alphabetic order" do
        expect(@names).to eq(["beer", "beer pong"])
      end
    end

    context "when some item type's name matches the prefix but none is owned by specified user" do
      let(:prefix) { "beer" }
      let(:user) { users(:nobody) }

      it "returns nothing" do
        expect(@names).to be_empty
      end
    end

    context "when no item type's name matches the prefix" do
      let(:prefix) { "block hole" }
      let(:user) { users(:danliu) }

      it "returns nothing" do
        expect(@names).to be_empty
      end
    end
  end

  describe "#descendant_types" do
    it "returns all descedant types" do
      drink = ItemType.find_by_name("drink")

      expect(drink.descendant_types).to match_array(
        ItemType.where(name: ["wine", "beer", "ginger beer", "craft beer"]).to_a
      )
    end

    it "returns nothing for item type without any child" do
      beer_pong = ItemType.find_by_name("beer pong")

      expect(beer_pong.descendant_types).to be_empty
    end
  end
end
