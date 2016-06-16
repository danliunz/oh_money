class CreateExpenseReportCriteria
  attr_reader :user, :params

  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    @criteria = ExpenseReport::Criteria.new(user: user)

    validate_and_set_params
  end

  def value
    @criteria
  end

  private

  def validate_and_set_params
    validate_and_set_root_item_type
    validate_and_set_tag
    validate_and_set_date_range
    validate_and_set_aggregation_mode

    valid_crtieria?
  end

  def validate_and_set_root_item_type
    item_type_name = @params[:root_item_type] && @params[:root_item_type][:name]

    unless item_type_name.blank?
      item_type = ItemType.find_by(name: item_type_name, user: user)

      if item_type
        @criteria.root_item_type = item_type
      else
        @criteria.root_item_type.errors.add(:name, "no purchase history for #{item_type_name}")
      end
    end
  end

  def validate_and_set_tag
    tag_name = @params[:tag] && @params[:tag][:name]

    unless tag_name.blank?
      tag = Tag.find_by_name(tag_name)

      if tag
        @criteria.tag = tag
      else
        @criteria.tag.errors.add(:name, "unrecognized tag #{tag_name}")
      end
    end
  end

  def validate_and_set_date_range
    begin
      unless @params[:begin_date].blank?
        @criteria.begin_date = Date.parse(@params[:begin_date])
      end
    rescue ArgumentError
      @criteria.errors.add(:begin_date, "invalid date format")
    end

    begin
      unless @params[:end_date].blank?
        @criteria.end_date = Date.parse(@params[:end_date])
      end
    rescue ArgumentError
      @criteria.errors.add(:end_date, "invalid date format")
    end
  end

  def validate_and_set_aggregation_mode
    mode = @params[:aggregation_mode]

    unless mode.blank?
      if ExpenseReport::Criteria::AGGREGATION_MODES.include?(mode)
        @criteria.aggregation_mode = mode
      else
        @criteria.errors.add(:aggregation_mode, "invalid aggregation mode #{mode}")
      end
    end
  end

  def valid_crtieria?
    @criteria.errors.empty? &&
    @criteria.root_item_type.errors.empty? &&
    @criteria.tag.errors.empty?
  end
end