module ExpenseReportsHelper
  def report_as_data_points(report)
    return "" if report.expense_history.empty?

    case report.criteria.aggregation_mode
    when "daily"
      daily_report_as_data_points(report)
    when "weekly"
      weekly_report_as_data_points(report)
    when "monthly"
      monthly_report_as_data_points(report)
    end
  end

  def date_to_display(date)
    date ? date.strftime("%Y-%m-%d") : "<not given>"
  end

  private

  def daily_report_as_data_points(report)
    (report.begin_time_unit .. report.end_time_unit).map do |date|
      "{ x: new Date(#{date.year}, #{date.month - 1}, #{date.day})," +
      "  y: #{report.expense_history[date] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def weekly_report_as_data_points(report)
    # format of time unit: <year in 4 digits><week number in 2 digits>
    # e.g. 201601 (which means the first week of year 2016)
    begin_year = report.begin_time_unit / 100
    begin_week = report.begin_time_unit % 100

    end_year = report.end_time_unit / 100
    end_week = report.end_time_unit % 100

    if begin_year == end_year
      year_weeks = (report.begin_time_unit .. report.end_time_unit)
    else
      weeks_of_begin_year =
        (report.begin_time_unit .. begin_year * 100 + number_of_weeks(begin_year)).to_a

      weeks_of_middle_years =
        (begin_year + 1 .. end_year - 1).map do |year|
          (year * 100 + 1 .. year * 100 + number_of_weeks(year)).to_a
        end.flatten

      weeks_of_end_year = (end_year * 100 + 1 .. report.end_time_unit).to_a

      year_weeks = weeks_of_begin_year + weeks_of_middle_years + weeks_of_end_year
    end

    year_weeks.map do |yearweek|
      "{ label: 'week #{yearweek % 100}, #{yearweek / 100}', " +
      "  y: #{report.expense_history[yearweek] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def number_of_weeks(year)
    Date.new(year, 12, 28).cweek # answer from stack overflow :)
  end

  def monthly_report_as_data_points(report)
    # format of time unit: <year in 4 digits><month in 2 digits>
    # e.g. 201601 (which means the first month of year 2016)
    begin_year = report.begin_time_unit / 100
    begin_month = report.begin_time_unit % 100

    end_year = report.end_time_unit / 100
    end_month = report.end_time_unit % 100

    if begin_year == end_year
      year_months = (report.begin_time_unit .. report.end_time_unit)
    else
      months_of_begin_year = (report.begin_time_unit .. begin_year * 100 + 12).to_a

      months_of_middle_years =
        (begin_year + 1 .. end_year - 1).map do |year|
          (year * 100 + 1 .. year * 100 + 12).to_a
        end.flatten

      months_of_end_year = (end_year * 100 + 1 .. report.end_time_unit).to_a

      year_months = months_of_begin_year + months_of_middle_years + months_of_end_year
    end

    year_months.map do |yearmonth|
      "{ label: '#{ Date::ABBR_MONTHNAMES[yearmonth % 100] } #{ yearmonth / 100 }', " +
      "  y: #{report.expense_history[yearmonth] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end
end