class ExpenseEntriesController < ApplicationController
  before_action :require_authorized_user, only: [:show, :edit, :delete]

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

  def show
    @expense_entry = ExpenseEntry.find(params[:id])

    # if user edits or deletes the expense entry from 'show' page,
    # expect the redirected URL to be one leading to 'show' page (if any)
    remember_return_url(request.env["HTTP_REFERER"] || list_expense_entries_url)
  end

  def edit
    @expense_entry = ExpenseEntry.find(params[:id])
    update_expense_entry =
      UpdateExpenseEntry.new(@expense_entry, expense_entry_params)

    if update_expense_entry.call
      redirect_to take_return_url,
        notice: "Expense entry for #{@expense_entry.item_type.name} is updated"
    else
      render 'show'
    end
  end

  def list
    if show_expense_history_criteria_form_only?
      create_empty_expense_history
    else
      @expense_history = CreateExpenseHistory.new(current_user, expense_history_params).call

      @expense_history.entries =
        @expense_history.entries.paginate(page: params[:page], per_page: 10)
    end
  end

  def delete
    expense_entry = ExpenseEntry.find(params[:id])

    if expense_entry.destroy
      redirect_to :back,
        notice: "expense entry for #{expense_entry.item_type.name} is deleted"
    else
      redirect_to :back,
        alert: "fail to delete expense entry for #{expense_entry.item_type.name}"
    end
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

  def create_blank_expense_entry
    @expense_entry = ExpenseEntry.new(
      item_type: ItemType.new,
      tags: []
    )
  end

  def remember_return_url(url)
    session[:expense_entries_return_url] = url
  end

  def take_return_url
    return_url = session[:expense_entries_return_url]
    session[:expense_entries_return_url] = nil

    return_url
  end

  def require_authorized_user
    if ExpenseEntry.find(params[:id]).user != current_user
      redirect_to signin_url, alert: "Authorization failure. Try signin as another user"
    end
  end
end
