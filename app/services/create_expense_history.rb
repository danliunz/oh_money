class CreateExpenseHistory
  def initialize(user, expense_history_params)
    @user = user
    @params = expense_history_params
  end

  def call
    @expense_history = ExpenseHistory.new(@params)

    if @expense_history.valid?
      @expense_history.entries = ExpenseEntry.history(
        @user, @expense_history.begin_date, @expense_history.end_date
      )

      @expense_history.date_to_cost_sum = Hash[
        ExpenseEntry.group_cost_by_day(
          @user, @expense_history.begin_date, @expense_history.end_date
        )
      ]
      @expense_history.date_to_cost_sum.default = 0
    else
      @expense_history.entries = ExpenseEntry.none
    end

    @expense_history
  end
end