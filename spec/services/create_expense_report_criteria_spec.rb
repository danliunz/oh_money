require "rails_helper"

RSpec.describe CreateExpenseReportCriteria, type: :service do
  fixtures :users, :item_types, :tags

  let(:user) { users(:danliu) }
  subject(:service) { described_class.new(user, params) }

  describe "#call" do
    context "when multiple users own items of the same name" do
      let(:params) do
        { root_item_type: { name: "wine" } }
      end

      it "chooses the item type belonging to the specified user" do
        expect(service.call).to be true
        expect(service.value.root_item_type).to eq(ItemType.find_by(name: "wine", user: user))
      end
    end

    context "when anothe user owns a tag of the same name" do
      let(:params) do
        { tag: { name: "@countdown" } }
      end

      it "chooses the tag belonging to the specified user" do
        expect(service.call).to be true
        expect(service.value.tag). to eq(Tag.find_by(name: "@countdown", user: user))
      end
    end

    context "when unrecongizned item_type name is given " do
      let(:params) do
        {
          root_item_type: { name: "not_exist" }
        }
      end

      it "fails" do
        expect(service.call).to be false

        expect(service.value.root_item_type.errors[:name].first)
          .to include("no purchase history for not_exist")
      end
    end

    context "when unrecognized tag is given" do
      let(:params) do
        {
          tag: { name: "not_exist" }
        }
      end

      it "fails" do
        expect(service.call).to be false

        expect(service.value.tag.errors[:name].first)
          .to include("unrecognized tag not_exist")
      end
    end

    context "when invalid date is given" do
      let(:params) do
        {
          begin_date: "invalid_date",
          end_date: "invalid_date"
        }
      end

      it "fails" do
        expect(service.call).to be false

        expect(service.value.errors[:begin_date].first)
          .to include("invalid date format")
        expect(service.value.errors[:end_date].first)
          .to include("invalid date format")
      end
    end

    context "when invalid aggregation mode is given" do
      let(:params) do
        {
          aggregation_mode: "<invalid>"
        }
      end

      it "fails" do
        expect(service.call).to be false

        expect(service.value.errors[:aggregation_mode].first)
          .to  include("invalid aggregation mode <invalid>")
      end
    end

    context "when empty params is given" do
      let(:params) { {} }

      it "succeeds and create a blank criteria" do
        expect(service.call).to be true

        criteria = service.value
        expect(criteria.root_item_type.name).to be_nil
        expect(criteria.tag.name).to be_nil
        expect(criteria.begin_date).to be_nil
        expect(criteria.end_date).to be_nil
        expect(criteria.aggregation_mode).to eq("daily")
      end
    end
  end
end