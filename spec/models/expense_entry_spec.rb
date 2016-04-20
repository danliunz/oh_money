require "rails_helper"

RSpec.describe ExpenseEntry, type: :model do
  fixtures :users, :expense_entries
  let(:user) { users(:danliu) }

  describe "#history" do
    before(:each) do
      @expense_entries = ExpenseEntry.history(user, begin_date, end_date)
    end

    context "when given neither begin_date nor end_date" do
      let(:begin_date) { "" }
      let(:end_date) { " " }

      it "returns all expense entries for the user" do
        expect(@expense_entries.size).to eq(7)
      end

      it "returns expense entries ordered by purchase_date descendingly" do
        purchase_dates = @expense_entries.map(&:purchase_date)

        expect(purchase_dates.sort { |a, b| b <=> a} ).to eq(purchase_dates)
      end
    end

    context "when begin_date is given" do
      let(:begin_date) { "2016-01-02" }
      let(:end_date) { "" }

      it "returns expense entries after the begin_date" do
        expect(@expense_entries.size).to eq(5)
        expect(@expense_entries.last.item_type.name).to eq("wine")
      end
    end

    context "when end_date is given" do
      let(:begin_date) { " " }
      let(:end_date) { "2016-01-05" }

      it "returns expense entries before the end_date" do
        expect(@expense_entries.size).to eq(6)
        expect(@expense_entries.first.item_type.name).to eq("craft beer")
      end
    end
  end
end