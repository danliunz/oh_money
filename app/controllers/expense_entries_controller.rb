class ExpenseEntriesController < ApplicationController
  def create_form
    if flash[:last_item_type_id]
      @last_item_type = ItemType.find(flash[:last_item_type_id])
    end

    create_blank_expense_entry
  end

  def create
    create_expense_entry =
      CreateExpenseEntry.new(expense_entry_params, current_user)

    if create_expense_entry.call
      expense_entry = create_expense_entry.value

      flash[:last_item_type_id] = expense_entry.item_type.id
      redirect_to create_expense_entry_url
    else
      @expense_entry = create_expense_entry.value
      flash.now.alert = create_expense_entry.error

      render "create_form"
    end
  end

  def list
    if show_expense_history_criteria_form_only?
      create_empty_expense_history
    else
      @expense_history = ExpenseHistory.new(expense_history_params)

      if @expense_history.valid?
        @expense_history.entries = ExpenseEntry.history(
          current_user, @expense_history.begin_date, @expense_history.end_date
        )
      else
        @expense_history.entries = ExpenseEntry.none
      end
    end

    paginate_expense_entries
  end

  private

  def expense_entry_params
    params
      .require(:expense_entry)
      .permit(:cost, :purchase_date, item_type: :name, tags: [:name])
  end

  def expense_history_params
    params
      .require(:expense_history)
      .permit(:begin_date, :end_date)
  end

  def show_expense_history_criteria_form_only?
    params[:view_history].blank?
  end

  def create_empty_expense_history
    @expense_history = ExpenseHistory.new(entries: ExpenseEntry.none)
  end

  def paginate_expense_entries
    @expense_history.entries =
      @expense_history.entries.paginate(page: params[:page], per_page: 10)
  end

  def create_blank_expense_entry
    @expense_entry = ExpenseEntry.new(
      item_type: ItemType.new,
      tags: []
    )
  end
end
