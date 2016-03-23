require "rails_helper"

RSpec.describe CreateExpenseReport, type: :service do
  fixtures :users, :item_types, :item_type_relations, :expense_entries

  subject(:service) do
    described_class.new(
      user, root_item_type, date_range.begin, date_range.end
    )
  end
  let(:user) { users(:danliu) }

  describe "#aggregate_by_date" do
    context "when given item_type with no children types" do
      let(:root_item_type) { ItemType.find_by_name!("wine") }
      let(:date_range) { Date.new(2016, 1, 1) .. Date.new(2016, 1, 3) }

      it "returns report aggregating expense by date for the item_type only" do
        report = service.aggregate_by_day

        expect(report.user).to eq(user)
        expect(report.root_item_type).to eq(root_item_type)
        expect(report.begin_date).to eq(Date.new(2016, 1, 1))
        expect(report.end_date).to eq(Date.new(2016, 1, 3))

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history["2016-01-01"]).to eq(1000)
        expect(expense_history["2016-01-02"]).to eq(1000)
        expect(expense_history["2016-01-03"]).to eq(0)
      end
    end
  end

  context "when given item_type with children types" do
    let(:root_item_type) { ItemType.find_by_name!("drink") }
    let(:date_range) { Date.new(2016, 1, 1) .. Date.new(2016, 1, 4) }

    it "returns report aggregating expense by date for both item_type and its children" do
      report = service.aggregate_by_day

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history["2016-01-01"]).to eq(3000)
      expect(expense_history["2016-01-02"]).to eq(1000)
      expect(expense_history["2016-01-03"]).to eq(500)
    end
  end

  context "when begin_date is not given" do
    let(:root_item_type) { ItemType.find_by_name!("beer") }
    let(:date_range) { Struct.new(:begin, :end).new(nil, Date.new(2016, 12, 30)) }

    it "returns report from start of history" do
      report = service.aggregate_by_day

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history["2016-01-01"]).to eq(2000)
      expect(expense_history["2016-01-02"]).to eq(0)
      expect(expense_history["2016-01-03"]).to eq(500)
      expect(expense_history["2016-01-05"]).to eq(450)
    end
  end

  context "when end_date is not given" do
    let(:root_item_type) { ItemType.find_by_name!("drink") }
    let(:date_range) { Struct.new(:begin, :end).new(Date.new(2016, 1, 2), nil) }

    it "returns report until end of history" do
      report = service.aggregate_by_day

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history["2016-01-01"]).to eq(0)
      expect(expense_history["2016-01-02"]).to eq(1000)
      expect(expense_history["2016-01-03"]).to eq(500)
      expect(expense_history["2016-01-05"]).to eq(450)
    end
  end

  context "when item_type is not given" do
    let(:root_item_type) { nil }
    let(:date_range) { Date.new(2016, 1, 1) .. Date.new(2016, 1, 5) }

    it "returns report of all expensen entries" do
      report = service.aggregate_by_day

      expect(report.root_item_type).to be_nil

      expense_history = report.expense_history
      expect(expense_history.length).to eq(4)
      expect(expense_history["2016-01-01"]).to eq(3000)
      expect(expense_history["2016-01-02"]).to eq(1000)
      expect(expense_history["2016-01-03"]).to eq(500 + 1510)
      expect(expense_history["2016-01-05"]).to eq(450)
    end
  end
end
