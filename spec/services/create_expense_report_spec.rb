require "rails_helper"

RSpec.describe CreateExpenseReport, type: :service do
  fixtures :users, :item_types, :item_type_relations, :expense_entries, :tags

  let(:user) { users(:danliu) }
  subject(:service)  { described_class.new(user, params) }

  describe "#aggregate_by_date" do
    context "when given item_type with no children types" do
      let(:params) do
        {
          root_item_type: { name: "wine" },
          begin_date: "2016-01-01",
          end_date: "2016-01-03"
        }
      end

      it "returns report aggregating expense by date for the item_type only" do
        report = service.call

        expect(report).to be_valid

        expect(report.user).to eq(user)
        expect(report.root_item_type.name).to eq("wine")
        expect(report.begin_date).to eq(Date.new(2016, 1, 1))
        expect(report.end_date).to eq(Date.new(2016, 1, 3))

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history[Date.parse("2016-01-01")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-03")]).to eq(0)
      end
    end
  end

  context "when given item_type with children types" do
    let(:params) do
      {
        root_item_type: { name: "drink" },
        begin_date: "2016-01-01",
        end_date: "2016-01-04"
      }
    end

    it "returns report aggregating expense by date for both item_type and its children" do
      report = service.call

      expect(report).to be_valid

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(3000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
    end
  end

  context "when begin_date is not given" do
    let(:params) do
      {
        root_item_type: { name: "beer" },
        end_date: "2016-12-30"
      }
    end

    it "returns report from start of history" do
      report = service.call

      expect(report).to be_valid

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(2000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(0)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
    end
  end

  context "when end_date is not given" do
    let(:params) do
      {
        root_item_type: { name: "drink" },
        begin_date: "2016-1-2"
      }
    end

    it "returns report until end of history" do
      report = service.call

      expect(report).to be_valid

      expense_history = report.expense_history
      expect(expense_history.length).to eq(3)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(0)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
    end
  end

  context "when item_type is not given" do
    let(:params) do
      {
        root_item_type: { name: "" },
        begin_date: "2016-1-1",
        end_date: "2016-01-5"
      }
    end

    it "returns report of all expensen entries" do
      report = service.call

      expect(report).to be_valid
      expect(report.root_item_type).not_to be_persisted

      expense_history = report.expense_history
      expect(expense_history.length).to eq(4)
      expect(expense_history[Date.parse("2016-01-01")]).to eq(3000)
      expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      expect(expense_history[Date.parse("2016-01-03")]).to eq(500 + 1510)
      expect(expense_history[Date.parse("2016-01-05")]).to eq(450)
    end
  end

  context "when empty params is given" do
    let(:params) { {} }

    it "returns report of whole expense history on all items" do
      report = service.call

      expect(report).to be_valid

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
      let(:params) do
        {
          root_item_type: { name: "drink" },
          tag: { name: "@countdown" },
          begin_date: "2016-1-1",
          end_date: "2016-01-5"
        }
      end

      before(:each) do
        expense_entries(:entry_1).tags << tags(:at_countdown)
        expense_entries(:entry_3).tags << tags(:at_countdown)
        expense_entries(:entry_4).tags << tags(:at_newworld)
      end

      it "returns report of expense entries with the tag and item_type" do
        report = service.call

        expect(report).to be_valid

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history[Date.parse("2016-01-01")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-02")]).to eq(1000)
      end
    end

    context "when item_type is not given" do
      let(:params) do
        {
          tag: { name: "@newworld" },
          begin_date: "2016-1-1",
          end_date: "2016-01-3"
        }
      end

      before(:each) do
        expense_entries(:entry_1).tags << tags(:at_newworld)
        expense_entries(:entry_4).tags << tags(:at_newworld)
        expense_entries(:entry_6).tags << tags(:at_newworld)
      end
      it "returns report of expense entries with the tag" do
        report = service.call

        expect(report).to be_valid

        expense_history = report.expense_history
        expect(expense_history.length).to eq(2)
        expect(expense_history[Date.parse("2016-01-01")]).to eq(1000)
        expect(expense_history[Date.parse("2016-01-02")]).to eq(0)
        expect(expense_history[Date.parse("2016-01-03")]).to eq(500)
      end
    end
  end
end
