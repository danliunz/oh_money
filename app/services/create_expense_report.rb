class CreateExpenseReport
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

    aggregate(relation)
  end

  def aggregate(relation)
    case @criteria.aggregation_mode
    when "daily"
      relation
        .group(:purchase_date)
        .order(purchase_date: :asc)
        .pluck("purchase_date as time_unit", "SUM(cost) as cost")
        .map do |datetime, cost|
          [Date.new(datetime.year, datetime.month, datetime.day), cost]
        end
    when "weekly"
      # TODO: MySQL specific SQL?
      relation
        .group("yearweek(purchase_date)")
        .order("yearweek(purchase_date) ASC")
        .pluck("yearweek(purchase_date) as time_unit", "SUM(cost) as cost")
    when "monthly"
      # TODO: MySQL specific SQL?
      relation
        .group("extract(year_month from purchase_date)")
        .order("extract(year_month from purchase_date) ASC")
        .pluck("extract(year_month from purchase_date) as time_unit", "SUM(cost) as cost")
    end
  end

  # convert array of {purchase_date, cost} to { :purchase_date => cost }
  def expense_history_as_hash(expense_history)
    result = Hash.new(0)

    expense_history.each do |time_unit, cost|
      result[time_unit] = cost
    end

    result
  end
end