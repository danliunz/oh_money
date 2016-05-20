class ExpenseEntry < ActiveRecord::Base
  CENTS_MULTIPLIER = 100.0

  belongs_to :item_type
  belongs_to :user, class_name: "Account::User"
  has_and_belongs_to_many :tags, join_table: "expense_entry_tags"

  validates_numericality_of :cost, only_integer: true, greater_than_or_equal_to: 0,
    message: "is not valid money"
  validates_presence_of :purchase_date,
    message: "is not valid date"

  validates_presence_of :item_type, :user
  validates_associated :item_type, :tags

  scope :at_or_after_date, ->(date) { where("purchase_date >=?", date) unless date.blank? }
  scope :at_or_before_date, ->(date) { where("purchase_date <= ?", date) unless date.blank? }

  scope :history, ->(user, begin_date, end_date) do
     where(user: user)
      .at_or_after_date(begin_date)
      .at_or_before_date(end_date)
      .includes(:tags)
      .includes(:item_type)
      .order(purchase_date: :desc, created_at: :desc)
  end

  scope :group_cost_by_day, ->(user, begin_date, end_date) do
    group(:purchase_date)
      .at_or_after_date(begin_date)
      .at_or_before_date(end_date)
      .pluck("purchase_date, sum(cost)")
  end
end
