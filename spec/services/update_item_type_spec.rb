require "rails_helper"

RSpec.describe UpdateItemType, type: :service do
  fixtures :users, :item_types, :item_type_relations

  let(:user) { users(:danliu) }

  subject(:service) do
    described_class.new(item_type, params)
  end

  describe "#call" do
    context "when redundant parents are given" do
      let(:item_type) { item_types(:premium_craft_beer) }
      let(:params) do
        { parents: ["beer", "drink" ] }
      end

      it "succeeds and only keeps most direct parents" do
        expect(service.call).to be true

        expect(item_type.parents).to contain_exactly(item_types(:beer))
      end
    end

    context "when given parents contains item type itself" do
      let(:item_type) { item_types(:premium_craft_beer) }
      let(:params) do
        {
          parents: [ "premium craft beer", "craft beer" ]
        }
      end

      it "succeeds and item type will not become its own parent" do
        expect(service.call).to be true

        expect(item_type.parents).to contain_exactly(item_types(:craft_beer))
      end
    end

    context "when item type's child is given as parent" do
      let(:item_type) { item_types(:beer) }
      let(:params) do
        {
          parents: ["drink", "premium craft beer"]
        }
      end

      it "fails" do
        expect(service.call).to be false

        expect(service.error).to match(
          "category 'premium craft beer' belongs to 'beer'"
        )
      end
    end
  end
end
