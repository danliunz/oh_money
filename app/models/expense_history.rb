class ExpenseHistory
  include ActiveModel::Model

  attr_accessor :begin_date, :end_date, :entries

  validates_each :begin_date, :end_date, allow_blank: true do |record, attr, value|
    begin
      Date.parse(value)
    rescue ArgumentError
      record.errors.add(attr, "is not valid date")
    end
  end
end