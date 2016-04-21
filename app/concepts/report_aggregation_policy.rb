module ReportAggregationPolicy
  def aggregate_by_sql(db_relation, aggregation_mode)
    db_relation = db_relation.group("time_unit").order("time_unit asc")

    case aggregation_mode
    when "daily"
      db_relation
        .pluck("purchase_date as time_unit", "SUM(cost) as cost")
        .map { |datetime, cost| [datetime.to_date, cost] }
    when "weekly"
      # extract yearweek as integer, e.g. 201601
      db_relation.pluck(
        "cast(extract(isoyear from purchase_date) * 100 + extract(week from purchase_date) as integer) as time_unit",
        "sum(cost) as cost"
      )
    when "monthly"
      # extrat yearmonth as integer, e.g. 201602
      db_relation.pluck(
        "cast(extract(year from purchase_date) * 100 + extract(month from purchase_date) as integer) as time_unit",
        "SUM(cost) as cost"
      )
    else
      raise ArgumentError, "invalid report aggregation mode: #{aggregation_mode}"
    end
  end

  def aggregated_data_as_json(report)
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

  private

  def daily_report_as_data_points(report)
    (report.begin_time_unit .. report.end_time_unit).map do |date|
      "{ x: new Date(#{date.year}, #{date.month - 1}, #{date.day})," +
      "  y: #{report.expense_history[date] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def weekly_report_as_data_points(report)
    year_weeks = calculate_year_weeks(report)

    year_weeks.map do |yearweek|
      "{ label: 'week #{yearweek % 100}, #{yearweek / 100}', " +
      "  y: #{report.expense_history[yearweek] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def calculate_year_weeks(report)
    # format of time unit: <year in 4 digits><week number in 2 digits>
    # e.g. 201601 (which means the first week of year 2016)
    begin_year = report.begin_time_unit / 100
    end_year = report.end_time_unit / 100

    if begin_year == end_year
      year_weeks = (report.begin_time_unit .. report.end_time_unit)
    else
      weeks_of_begin_year =
        (report.begin_time_unit .. begin_year * 100 + number_of_weeks(begin_year)).to_a

      weeks_of_middle_years =
        (begin_year + 1 .. end_year - 1).map do |year|
          1.upto(number_of_weeks(year)).map { |week| year * 100 + week }
        end.flatten

      weeks_of_end_year = (end_year * 100 + 1 .. report.end_time_unit).to_a

      year_weeks = weeks_of_begin_year + weeks_of_middle_years + weeks_of_end_year
    end

    year_weeks
  end

  def number_of_weeks(year)
    Date.new(year, 12, 28).cweek # answer from stack overflow :)
  end

    def monthly_report_as_data_points(report)
    year_months = calculate_year_months(report)

    year_months.map do |yearmonth|
      "{ label: '#{ Date::ABBR_MONTHNAMES[yearmonth % 100] } #{ yearmonth / 100 }', " +
      "  y: #{report.expense_history[yearmonth] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def calculate_year_months(report)
    # format of time unit: <year in 4 digits><month in 2 digits>
    # e.g. 201601 (which means the first month of year 2016)
    begin_year = report.begin_time_unit / 100
    end_year = report.end_time_unit / 100

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

    year_months
  end
end