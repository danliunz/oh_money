class CreateExpenseReport
  def initialize(user, root_item_type, begin_date, end_date)
    @user = user
    @root_item_type = root_item_type
    @begin_date = begin_date
    @end_date = end_date
  end

  def aggregate_by_day
    report = ExpenseReport.new(@user, @root_item_type, @begin_date, @end_date)

    item_types = item_type_and_its_descendants
    report.expense_history = expense_history(item_types)

    report
  end

  private

  def item_type_and_its_descendants
    if @root_item_type
      [@root_item_type].concat(@root_item_type.descendant_types)
    end
  end

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
      .pluck(:purchase_date, 'SUM(cost) as cost')
  end
end