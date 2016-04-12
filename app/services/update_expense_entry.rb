class UpdateExpenseEntry
  include ExpenseEntryServiceHelper

  def initialize(expense_entry, params)
    @expense_entry = expense_entry
    @user = @expense_entry.user
    @params = params
  end

  def call
    ExpenseEntry.transaction { update }
  rescue
    false
  else
    true
  end

  private

  def update
    update_cost
    update_purchase_date
    set_tags

    @expense_entry.save!
  end

  def update_cost
    if @params[:cost]
      @expense_entry.cost = cost_in_cents
    end
  end

  def update_purchase_date
    if @params[:purchase_date]
      @expense_entry.purchase_date = purchase_date
    end
  end
end