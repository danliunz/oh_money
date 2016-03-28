class ExpenseReport
  include ActiveModel::Model

  attr_reader :user, :root_item_type, :expense_history
  attr_accessor :begin_date, :end_date

  def initialize(user, root_item_type = nil, begin_date = nil, end_date = nil)
    @user = user
    @root_item_type = root_item_type
    @begin_date= begin_date
    @end_date = end_date
    @expense_history = Hash.new(0)
  end

  # _expense_history_ : array of [purchase_date, cost_in_cents]
  def expense_history=(expense_history)
    expense_history.each do |purchase_date, cost_in_cents|
      @expense_history[purchase_date.strftime('%Y-%m-%d')] = cost_in_cents
    end
  end

  def as_json(options = nil)
    {
      user: { name: user.name },
      root_item_type: root_item_type_as_json,
      begin_date: begin_date,
      end_date: end_date,
      expense_history: expense_history
    }
  end

  private

  def root_item_type_as_json
    if root_item_type
      {
        name: root_item_type.name,
        description: root_item_type.description
      }
    end
  end
end