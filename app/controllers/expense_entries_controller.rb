class ExpenseEntriesController < ApplicationController
  def create_form
    create_blank_expense_entry
  end

  def create
    create_expense_entry =
      CreateExpenseEntry.new(expense_entry_params, current_user)

    if create_expense_entry.call
      expense_entry = create_expense_entry.value
      redirect_to create_expense_entry_url,
        notice: "expense entry for #{expense_entry.item_type.name} is saved"
    else
      @expense_entry = create_expense_entry.value
      flash.alert = create_expense_entry.error

      render "create_form"
    end
  end

  private

  def expense_entry_params
    params
      .require(:expense_entry)
      .permit(:cost, :purchase_date, item_type: :name, tags: [:name])
  end

  def create_blank_expense_entry
    @expense_entry = ExpenseEntry.new(
      item_type: ItemType.new,
      tags: []
    )
  end
end
