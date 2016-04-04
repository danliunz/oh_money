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
      flash.now.alert = create_expense_entry.error

      render "create_form"
    end
  end

  def list
    if params[:view_list].blank?
      relation = ExpenseEntry.none
    else
      relation = ExpenseEntry.where(user: current_user)
        .includes(:tags)
        .includes(:item_type)
        .order(purchase_date: :desc)

      unless params[:start_date].blank?
        relation = relation.where("purchase_date >= ?", params[:start_date])
      end

      unless params[:end_date].blank?
        relation = relation.where("purchase_date <= ?", params[:end_date])
      end
    end

    @expense_entries = relation
      .paginate(page: params[:page], per_page: 10)
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
