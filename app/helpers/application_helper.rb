module ApplicationHelper
  def cost_to_display(cost)
    number_to_currency(cost / ExpenseEntry::CENTS_MULTIPLIER)
  end
end
