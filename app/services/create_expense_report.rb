class CreateExpenseReport
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    @report = ExpenseReport.new(user: @user)

    if validate_and_set_params
      update_by_expense_history
    end

    @report
  end

  private

  def validate_and_set_params
    validate_and_set_root_item_type
    validate_and_set_tag
    validate_and_set_date_range
    validate_and_set_aggregation_mode

    @report.valid?
  end


  def validate_and_set_aggregation_mode
    mode = @params[:aggregation_mode]

    if ExpenseReport.aggregation_modes.include?(mode)
      @report.aggregation_mode = mode
    else
      @report.errors.add(:aggregation_mode, "invalid aggregation mode #{mode}")
    end
  end

  def validate_and_set_tag
    tag_name = @params[:tag] && @params[:tag][:name]

    # we need to create Tag instance in all circumstances,
    # since 'form_for' in HTML view need non-nil model to work with
    if tag_name.blank?
      @report.tag = Tag.new
    else
      unless @report.tag = Tag.find_by_name(tag_name)
        @report.tag = Tag.new(name: tag_name)
        @report.tag.errors.add(:name, "unrecognized tag #{tag_name}")
      end
    end
  end

  def validate_and_set_root_item_type
    item_type_name = @params[:root_item_type] && @params[:root_item_type][:name]

    # we need to create ItemType instance in all circumstances,
    # since 'form_for' in HTML view need non-nil model to work with
    if item_type_name.blank?
      @report.root_item_type = ItemType.new
    else
      unless @report.root_item_type = ItemType.find_by_name(item_type_name)
        @report.root_item_type = ItemType.new(name: item_type_name)
        @report.root_item_type.errors.add(:name, "no purchase history for #{item_type_name}")
      end
    end
  end

  def validate_and_set_date_range
    begin
      @report.begin_date = @params[:begin_date].blank? ?
        nil : Date.parse(@params[:begin_date])
    rescue ArgumentError
      @report.errors.add(:begin_date, "invalid date format")
    end

    begin
      @report.end_date = @params[:end_date].blank? ?
        nil : Date.parse(@params[:end_date])
    rescue ArgumentError
      @report.errors.add(:end_date, "invalid date format")
    end
  end

  def update_by_expense_history
    expense_history = expense_history(item_type_and_its_descendants)

    if expense_history.empty?
      @report.root_item_type.errors.add(
        :name, "no purchase history for #{@report.root_item_type.name}"
      )
    else
      @report.begin_time_unit = expense_history.first[0]
      @report.end_time_unit = expense_history.last[0]

      @report.expense_history = expense_history_as_hash(expense_history)
    end
  end

  def item_type_and_its_descendants
    root_item_type = @report.root_item_type

    if root_item_type.persisted?
      GetItemTypeDescendants.new(root_item_type).call
        .concat([root_item_type])
    end
  end

  # returns array of { purchase_date, cost_in_dollars }
  def expense_history(item_types)
    relation = ExpenseEntry.where(user: @report.user)

    if item_types
      relation = relation.where(item_type: item_types)
    end

    if @report.tag.persisted?
      relation = relation.joins(
        "INNER JOIN expense_entry_tags join_table " +
        "ON join_table.expense_entry_id = expense_entries.id " +
        "AND join_table.tag_id = #{@report.tag.id}"
      )
    end

    if @report.begin_date
      relation = relation.where("purchase_date >= ?", @report.begin_date)
    end

    if @report.end_date
      relation = relation.where("purchase_date <= ?", @report.end_date)
    end

    aggregate(relation)
  end

  def aggregate(relation)
    case @report.aggregation_mode
    when "daily"
      relation
        .group(:purchase_date)
        .order(purchase_date: :asc)
        .pluck("purchase_date as time_unit", "SUM(cost) as cost")
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