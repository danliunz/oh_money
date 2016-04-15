require "rails_helper"

RSpec.describe CreateExpenseReport, type: :service do
  fixtures :users, :item_types, :item_type_relations, :expense_entries, :tags

  let(:user) { users(:danliu) }
  let(:aggregation_mode) { "daily" }
  let(:tag) { nil }

  let(:report_criteria) do
     ExpenseReport::Criteria.new(
       user: user,
       root_item_type: root_item_type,
       tag: tag,
       begin_date: begin_date,
       end_date: end_date,
       aggregation_mode: aggregation_mode
     )
  end
  subject(:service)  { described_class.new(report_criteria) }

  describe "#call" do
    context "when given item_type with no children types" do
      let(:root_item_type) { item_types(:wine) }
      let(:begin_date) { Date.parse("2016-01-01") }
      let(:end_date) { Date.parse("2016-03-03") }

      it "returns report aggregating expense by date for the item_type only" do
        report = service.call

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history[Date.parse("2016-01-01")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-03")]).to eq(0)
      end
    end
  end

  context "when given item_type with children types" do
    let(:root_item_type) { item_types(:drink) }
    let(:begin_date) { Date.parse("2016-01-01") }
    let(:end_date) { Date.parse("2016-01-04") }

    it "returns report aggregating expense by date for both item_type and its children" do
      report = service.call

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(3000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
    end
  end

  context "when begin_date is not given" do
    let(:root_item_type) { item_types(:beer) }
    let(:begin_date) { nil }
    let(:end_date) { Date.parse("2016-12-30") }

    it "returns report from start of history" do
      report = service.call

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(2000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(0)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
    end
  end

  context "when end_date is not given" do
    let(:root_item_type) { item_types(:drink) }
    let(:begin_date) { Date.parse("2016-1-2") }
    let(:end_date) { nil }

    it "returns report until end of history" do
      report = service.call

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(0)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
    end
  end

  context "when item_type is not given" do
    let(:root_item_type) { nil }
    let(:begin_date) { Date.parse("2016-1-1") }
    let(:end_date) { Date.parse("2016-01-5") }

    it "returns report of all expensen entries" do
      report = service.call

      expense_history = report.expense_history
      expect(expense_history.length).to eq(4)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(3000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500 + 1510)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
    end
  end

  context "when empty criteria is given" do
    let(:report_criteria) { ExpenseReport::Criteria.new(user: user) }

    it "returns report of whole expense history on all items" do
      report = service.call

      expense_history = report.expense_history
      expect(expense_history.length).to eq(5)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(1000 + 2000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500 + 1510)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
      expect(expense_history[Date.parse("2016-01-06")]).to eq(1300)
    end
  end

  context "when tag is given" do
    context "when item_type is given" do
      let(:root_item_type) { item_types(:drink) }
      let(:begin_date) { Date.parse("2016-1-1") }
      let(:end_date) { Date.parse("2016-01-5") }
      let(:tag) { tags(:at_countdown) }

      before(:each) do
        expense_entries(:entry_1).tags << tags(:at_countdown)
        expense_entries(:entry_3).tags << tags(:at_countdown)
        expense_entries(:entry_4).tags << tags(:at_newworld)
      end

      it "returns report of expense entries with the tag and item_type" do
        report = service.call

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history[Date.parse("2016-01-01")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      end
    end

    context "when item_type is not given" do
      let(:root_item_type) { nil }
      let(:tag) { tags(:at_newworld) }
      let(:begin_date) { Date.parse("2016-1-1") }
      let(:end_date) { Date.parse("2016-01-3") }

      before(:each) do
        expense_entries(:entry_1).tags << tags(:at_newworld)
        expense_entries(:entry_4).tags << tags(:at_newworld)
        expense_entries(:entry_6).tags << tags(:at_newworld)
      end
      it "returns report of expense entries with the tag" do
        report = service.call

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history[Date.parse("2016-01-01")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-02")]).to eq(0)
        expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
      end
    end

    context "when there is no purchase history for item_type" do
      let(:root_item_type) { item_types(:panda) }
      let(:begin_date) { nil }
      let(:end_date) { nil }

      it "returns empty report" do
        report = service.call

        expect(report.expense_history).to be_empty
      end
    end
  end
end
