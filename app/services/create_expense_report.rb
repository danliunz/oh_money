class CreateExpenseReport
  include ReportAggregationPolicy

  HIGH_PRICE_THRESHOLD = 200 * 100 # $20

  attr_reader :criteria

  def initialize(criteria)
    @criteria = criteria
  end

  def call
    @report = ExpenseReport.new(@criteria)

    query_expense_history
    calculate_average_cost_by_time_unit

    adjust_expense_history_by_high_price_purchases

    @report
  end

  private

  def query_expense_history
    expense_history = aggregate_cost_by_time_unit(expense_entries, @criteria.aggregation_mode)

    if expense_history.any?
      @report.begin_time_unit = expense_history.first[0]
      @report.end_time_unit = expense_history.last[0]
    end

    @report.expense_history = expense_history.to_h
  end

  def item_type_and_its_descendants
    @item_types ||= begin
      root_item_type = @criteria.root_item_type

      if root_item_type.id
        [root_item_type] + GetItemTypeDescendants.new(root_item_type).call
      end
    end
  end

  # Remove purchases with high price from report
  # and evenly distribute their cost across all time units.
  # It is to avoid large spikes from report graph which makes trend analysis difficult
  def adjust_expense_history_by_high_price_purchases
    high_price_expense_history =
      aggregate_cost_by_time_unit(expense_entries_with_high_price, @criteria.aggregation_mode)

    # 1. remove cost of high price purchases from report
    high_price_expense_history.each do |time_unit, cost|
      @report.expense_history[time_unit] -= cost
    end

    # 2. evenly distribute cost of high price purchases to all time units (including time units with 0 cost)
    average_cost_of_high_price_purchases =
      (
        high_price_expense_history.reduce(0.0) { |total_cost, (time_unit, cost)| total_cost + cost } /
        calculate_number_of_time_units_in_report_criteria
      ).round

    @report.expense_history.each_key do |time_unit|
      @report.expense_history[time_unit] += average_cost_of_high_price_purchases
    end

    @report.expense_history.default = average_cost_of_high_price_purchases
  end

  def expense_entries
    scope = ExpenseEntry.where(user: @criteria.user)

    item_types = item_type_and_its_descendants
    scope = scope.where(item_type: item_types) if item_types

    if @criteria.tag.id
      scope = scope.joins(
        "INNER JOIN expense_entry_tags join_table " +
        "ON join_table.expense_entry_id = expense_entries.id " +
        "AND join_table.tag_id = #{@criteria.tag.id}"
      )
    end

    if @criteria.begin_date
      scope = scope.where("purchase_date >= ?", @criteria.begin_date)
    end

    if @criteria.end_date
      scope = scope.where("purchase_date <= ?", @criteria.end_date)
    end

    scope
  end

  def expense_entries_with_high_price
    expense_entries.where("cost >= #{HIGH_PRICE_THRESHOLD}")
  end
end