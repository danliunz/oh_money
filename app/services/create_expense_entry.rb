class CreateExpenseEntry
  include ExpenseEntryServiceHelper

  attr_reader :error

  def initialize(params, user)
    @params = params
    @user = user
    @expense_entry = ExpenseEntry.new
  end

  def call
    ActiveRecord::Base.transaction { create }
  rescue
    false
  else
    true
  end

  def value
    @expense_entry
  end

  private

  def create
    @expense_entry.user = @user
    @expense_entry.item_type = find_or_create_item_type
    @expense_entry.cost = cost_in_cents
    @expense_entry.purchase_date = purchase_date

    set_tags

    @expense_entry.save!
  end

  def find_or_create_item_type
    ItemType.find_or_create_by(name: @params[:item_type]["name"], user: @user)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end