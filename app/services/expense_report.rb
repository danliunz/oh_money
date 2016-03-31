class ExpenseReport
  include ActiveModel::Model

  attr_accessor :user, :root_item_type, :tag, :begin_date, :end_date
  attr_accessor :expense_history

  def initialize(attributes = {})
    super

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
      expense_history: expense_history
    }
  end
end