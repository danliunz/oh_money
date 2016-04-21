module ExpenseReportsHelper
  include ReportAggregationPolicy

  def date_to_display(date)
    date ? date.strftime("%Y-%m-%d") : "<not given>"
  end
end