require 'rails_helper'

RSpec.describe CreateExpenseEntry, type: :service do
  describe "#call" do
    fixtures :users, :item_types, :tags
    let(:user) { users(:danliu) }
    subject(:service) { described_class.new(params, user) }

    context "with valid params" do
      let(:params) do
        {
          item_type: { "name" => "wine" },
          cost: "10.50",
          purchase_date: "2016-04-06",
          tags: [{ "name" => "@countdown" }, { "name" => "birthday" }]
        }
      end

      before(:each) { expect(service.call).to be true }

      it "creates a valid expense entry" do
        expect(service.value).to be_valid
      end

      it "persists a valid expense entry into DB" do
        new_entry = ExpenseEntry
          .where(user: user, item_type: item_types(:wine))
          .first

        expect(new_entry.user.name).to eq("danliu")
        expect(new_entry.item_type.name).to eq("wine")
        expect(new_entry.cost).to eq(1050)
        expect(new_entry.purchase_date).to eq(Date.new(2016, 4, 6))
        expect(new_entry.tags.map(&:name)).to contain_exactly("@countdown", "birthday")
      end

      context "with new item type" do
        let(:params) do
          {
            item_type: { "name" => "panda" }, # are you sure :)
            cost: "10000000.0",
            tags: [{ "name" => "@countdown" }]
          }
        end

        it "creates a item type into DB" do
          expect(ItemType.exists?(user: user, name: "panda")).to be true
        end
      end

      context "with new tags" do
        let(:params) do
          {
            item_type: { "name" => "wine" },
            cost: "20.01",
            tags: [{ "name" => "@newworld" }, { "name" => "wife birthday" }]
          }
        end

        it "creates tags into DB" do
          ["@newworld", "wife birthday"].each do |tag_name|
            expect(Tag.exists?(user: user, name: tag_name)).to be true
          end
        end
      end
    end
  end
end