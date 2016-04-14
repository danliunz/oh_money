# Note: the class overrides the ActiveModel valid? mechanism,
# do not use any ActiveModel validates_* methods for validations.
# TODO: find a better way to handle validations?
class ExpenseReport
  include ActiveModel::Model

  # report criteria
  attr_accessor :user, :root_item_type, :tag, :begin_date, :end_date, :aggregation_mode

  # report data
  attr_accessor :begin_time_unit, :end_time_unit, :expense_history

  def self.aggregation_modes
    ["daily", "weekly", "monthly"]
  end

  def initialize(attributes = {})
    super

    @aggregation_mode ||= "daily"
    @expense_history ||= Hash.new(0)
  end

  def valid?
    errors.empty? &&
    (root_item_type.nil? || root_item_type.errors.empty?) &&
    (tag.nil? || tag.errors.empty?)
  end

  def as_json(options = nil)
    {
      user: user.as_json,
      root_item_type: root_item_type && root_item_type.as_json,
      tag: tag && tag.as_json,
      begin_date: begin_date,
      end_date: end_date,
      begin_time_unit: begin_time_unit,
      end_time_unit: end_time_unit,
      expense_history: expense_history
    }
  end
end