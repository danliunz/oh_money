class ExpenseReport
  attr_accessor :criteria
  attr_accessor :begin_time_unit, :end_time_unit, :expense_history

  def initialize(criteria)
    @criteria = criteria
  end
end