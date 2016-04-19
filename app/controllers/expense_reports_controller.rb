class ExpenseReportsController < ApplicationController
  def create
    create_criteria = CreateExpenseReportCriteria.new(
      current_user, report_criteria_params
    )

    # TODO: get rid of .value if possible
    if create_criteria.call
      @report = CreateExpenseReport.new(create_criteria.value).call

      respond_to do |format|
        format.html
        format.json { render json: @report }
      end
    else
      @report_criteria = create_criteria.value

      respond_to do |format|
        format.html { render "criteria_form" }
        format.json { render json: { errors: @report_criteria.errors.full_messages } }
      end
    end
  end

  def criteria_form
    create_empty_report_criteria
  end

  private

  def report_criteria_params
    params[:expense_report_criteria] || {}
  end

  def create_empty_report_criteria
    @report_criteria = ExpenseReport::Criteria.new(user: current_user)
  end
end