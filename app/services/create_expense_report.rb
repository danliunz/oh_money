class CreateExpenseReport
  def initialize(user, root_item_type, begin_date, end_date)
    @user = user
    @root_item_type = root_item_type
    @begin_date = begin_date
    @end_date = end_date
  end

  def aggregate_by_day
    report = ExpenseReport.new(@user, @root_item_type)

    item_types = item_type_and_its_descendants

    expense_history = expense_history(item_types)
    report.expense_history = expense_history

    report.begin_date = @begin_date || begin_date_of(expense_history)
    report.end_date = @end_date || end_date_of(expense_history)

    report
  end

  private

  def item_type_and_its_descendants
    if @root_item_type
      [@root_item_type].concat(@root_item_type.descendant_types)
    end
  end

  # returns array of [purchase_date, total_cost_in_cents]
  def expense_history(item_types)
    relation = ExpenseEntry.where(user: @user)

    if item_types
      relation = relation.where(item_type: item_types)
    end

    if @begin_date
      relation = relation.where("purchase_date >= ?", @begin_date)
    end

    if @end_date
      relation = relation.where("purchase_date <= ?", @end_date)
    end

    relation
      .group(:purchase_date)
      .order(purchase_date: :asc)
      .pluck(:purchase_date, 'SUM(cost) as cost')
  end

  def begin_date_of(expense_history)
    time = expense_history.first.first
    Date.new(time.year, time.month, time.day)
  end

  def end_date_of(expense_history)
    time = expense_history.last.first
    Date.new(time.year, time.month, time.day)
  end
end