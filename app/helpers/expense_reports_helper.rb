module ExpenseReportsHelper
  def report_as_data_points(report)
    expense_history = report.expense_history

    (report.begin_date .. report.end_date).map do |date|
      "{ x: new Date(#{date.year}, #{date.month - 1}, #{date.day})," +
      "  y: #{expense_history[date]} }"
    end.join(",")
  end
end