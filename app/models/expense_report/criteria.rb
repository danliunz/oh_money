class ExpenseReport::Criteria
  include ActiveModel::Model

  AGGREGATION_MODES = %w{daily weekly monthly}

  attr_accessor :user, :root_item_type, :tag, :begin_date, :end_date
  attr_accessor :aggregation_mode

  def initialize(attributes = {})
    super

    @root_item_type ||= ItemType.new
    @tag ||= Tag.new
    @aggregation_mode ||= "daily"
  end
end