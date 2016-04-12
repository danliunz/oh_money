require "rails_helper"

RSpec.describe UpdateExpenseEntry, type: :service do
  fixtures :users, :expense_entries

  let(:user) { users(:danliu) }
  let(:expense_entry) { expense_entries(:entry_1)}

  subject(:service) { UpdateExpenseEntry.new(expense_entry, params)}

  describe "#call" do
    context "with valid params" do
      let(:params) do
        {
          cost: "30.0",
          purchase_date: "2016-04-06",
          tags: [{ "name" => "@newworld" }, { "name" => "birthday" }]
        }
      end

      it "update the expense entry" do
        expect(service.call).to be true
        expect(expense_entry.item_type.name).to eq("wine")
        expect(expense_entry.cost).to eq(3000)
        expect(expense_entry.purchase_date.strftime("%Y-%m-%d")).to eq("2016-04-06")
        expect(expense_entry.tags.map(&:name)).to contain_exactly("@newworld", "birthday")
      end
    end
  end
end
