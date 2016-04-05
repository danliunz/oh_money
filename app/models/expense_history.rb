class ExpenseHistory
  include ActiveModel::Model

  attr_accessor :begin_date, :end_date, :entries
end