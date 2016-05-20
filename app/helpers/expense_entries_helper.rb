module ExpenseEntriesHelper
  def group_expense_entries_by_purchase_date(expense_history)
    expense_entries_by_date = []

    current_date = nil
    expense_history.entries.each do |expense_entry|
      if current_date != expense_entry.purchase_date
        current_date = expense_entry.purchase_date

        expense_entries_by_date << {
          date: current_date,
          entries: [],
          total_cost: expense_history.date_to_cost_sum[current_date]
        }
      end

      expense_entries_by_date.last[:entries] << expense_entry
    end

    expense_entries_by_date
  end
end