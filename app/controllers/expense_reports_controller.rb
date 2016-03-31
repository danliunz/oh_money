class ExpenseReportsController < ApplicationController
  def aggregate_by_day
    create_report  = CreateExpenseReport.new(current_user, expense_report_params)

    @report = create_report.call
    if @report.valid?
      respond_to do |format|
        format.html
        format.json { render json: @report }
      end
    else
      respond_to do |format|
        format.html { render "criteria_form" }
        format.json { render json: { errors: @report.errors.full_messages } }
      end
    end
  end

  def criteria_form
    create_blank_report
  end

  private

  def expense_report_params
    params[:expense_report] || {}
  end

  def create_blank_report
    @report = ExpenseReport.new(
      user: current_user,
      root_item_type: ItemType.new,
      tag: Tag.new
    )
  end
end