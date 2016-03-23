class ExpenseReportsController < ApplicationController
  class ValidateParams
    attr_reader :error, :root_item_type, :begin_date, :end_date

    def initialize(params)
      @params = params
    end

    def call
      validate_and_set_root_item_type &&
      validate_and_set_date_range
    end

    private

    def validate_and_set_root_item_type
      item_type_name = @params[:root_item_type]
      if item_type_name.blank?
        @root_item_type = nil
      else
        @root_item_type = ItemType.find_by_name(item_type_name)
        if @root_item_type.nil?
          @error = "Item type '#{item_type_name}' does not exist"
          return false
        end
      end

      true
    end

    def validate_and_set_date_range
      begin
        @begin_date = @params[:begin_date].blank? ?
          nil : Date.parse(@params[:begin_date])

        @end_date = @params[:end_date].blank? ?
          nil : Date.parse(@params[:end_date])
      rescue ArgumentError
        @error = "Invalid begin_date or end_date param"
        return false
      end

      true
    end
  end

  def aggregate_by_day
    validate_params = ValidateParams.new(params)

    if validate_params.call
      create_report = CreateExpenseReport.new(
        current_user, validate_params.root_item_type,
        validate_params.begin_date, validate_params.end_date
      )

      report = create_report.aggregate_by_day

      render json: report
    else
      render json: { error: validate_params.error }
    end
  end
end