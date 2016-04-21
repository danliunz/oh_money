class CreateExpenseReport
  include ReportAggregationPolicy

  attr_reader :criteria

  def initialize(criteria)
    @criteria = criteria
  end

  def call
    @report = ExpenseReport.new(@criteria)

    update_report_by_expense_history

    @report
  end

  private

  def update_report_by_expense_history
    expense_history = expense_history(item_type_and_its_descendants)

    if expense_history.any?
      @report.begin_time_unit = expense_history.first[0]
      @report.end_time_unit = expense_history.last[0]
    end

    @report.expense_history = expense_history_as_hash(expense_history)
  end

  def item_type_and_its_descendants
    root_item_type = @criteria.root_item_type

    if root_item_type.id
      [root_item_type] + GetItemTypeDescendants.new(root_item_type).call
    end
  end

  # return array of [<time_unit>, <cost_in_cents>]
  def expense_history(item_types)
    relation = ExpenseEntry.where(user: @criteria.user)

    if item_types
      relation = relation.where(item_type: item_types)
    end

    # TODO: use object name instead of table name
    if @criteria.tag.id
      relation = relation.joins(
        "INNER JOIN expense_entry_tags join_table " +
        "ON join_table.expense_entry_id = expense_entries.id " +
        "AND join_table.tag_id = #{@criteria.tag.id}"
      )
    end

    if @criteria.begin_date
      relation = relation.where("purchase_date >= ?", @criteria.begin_date)
    end

    if @criteria.end_date
      relation = relation.where("purchase_date <= ?", @criteria.end_date)
    end

    aggregate_by_sql(relation, @criteria.aggregation_mode)
  end

  # convert array of {purchase_date, cost} to { :purchase_date => cost }
  def expense_history_as_hash(expense_history)
    # TODO: set default value 0 later
    result = Hash.new(0)

    expense_history.each do |time_unit, cost|
      result[time_unit] = cost
    end

    result
  end
end