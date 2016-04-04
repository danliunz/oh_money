require "rails_helper"

RSpec.describe GetItemTypeDescendants, type: :model do
  fixtures :users, :item_types, :item_type_relations

  subject(:service) { described_class.new(root_item_type) }

  describe "#call" do
    context "when root_item_type has children" do
      let(:root_item_type) { ItemType.find_by_name("drink") }

      it "returns all descendant types" do
        expect(service.call).to match_array(
          ItemType.where(name: ["wine", "beer", "ginger beer", "craft beer"]).to_a
        )
      end
    end

    context "when root_item_type has no child" do
      let(:root_item_type) { ItemType.find_by_name("beer pong") }

      it "returns empty array" do
        expect(service.call).to be_empty
      end
    end


    context "when circular dependency is present" do
      let(:root_item_type) { ItemType.find_by_name("drink") }

      before do
        # add circular dependency
        ItemTypeRelation.create!(
          child: ItemType.find_by_name("drink"),
          parent: ItemType.find_by_name("beer")
        )
      end

      it "raises exception" do
        expect { service.call }.to raise_error(ItemTypeRelation::CircularDependencyError)
      end
    end
  end
end