class ExpenseReport
  attr_accessor :criteria
  attr_accessor :begin_time_unit, :end_time_unit, :expense_history
  attr_accessor :average_cost_by_time_unit

  def initialize(criteria)
    @criteria = criteria
  end
end