module ExpenseEntriesHelper
  def group_expense_entries_by_purchase_date(expense_entries)
    expense_entries_by_date = []

    current_date = nil
    expense_entries.each do |expense_entry|
      if current_date != expense_entry.purchase_date
        current_date = expense_entry.purchase_date

        expense_entries_by_date << {
          date: current_date, entries: [], total_cost: 0
        }
      end

      expense_entries_by_date.last[:entries] << expense_entry
      expense_entries_by_date.last[:total_cost] += expense_entry.cost
    end

    expense_entries_by_date
  end
end