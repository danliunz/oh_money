module ExpenseEntriesHelper
  def group_expense_entries_by_purchase_date(expense_entries)
    expense_entries_by_date = []

    current_date = nil
    expense_entries.each do |expense_entry|
      if current_date != expense_entry.purchase_date
        current_date = expense_entry.purchase_date
        expense_entries_by_date << { date: current_date, entries: [] }
      end

      expense_entries_by_date.last[:entries] << expense_entry
    end

    expense_entries_by_date
  end

  def cost_to_display(cost)
    number_to_currency(cost / ExpenseEntry::CENTS_MULTIPLIER)
  end
end