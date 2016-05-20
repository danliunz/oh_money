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

  def calculate_average_cost_by_time_unit
    sum_of_cost = @report.expense_history.values.reduce(:+) || 0

    if sum_of_cost == 0
      @report.average_cost_by_time_unit = 0
    else
      number_of_time_units = calculate_number_of_time_units_in_report_criteria
      @report.average_cost_by_time_unit = sum_of_cost / number_of_time_units
    end
  end

  def calculate_number_of_time_units_in_report_criteria
    case @report.criteria.aggregation_mode
    when "daily"
      (
        @report.criteria.begin_date || @report.begin_time_unit || 0 ..
        @report.criteria.end_date || @report.end_time_unit || 0
      ).count
    when "weekly"
      calculate_year_weeks(
        get_yearweek(@report.criteria.begin_date) || @report.begin_time_unit,
        get_yearweek(@report.criteria.end_date) || @report.end_time_unit
      ).size
    when "monthly"
      calculate_year_months(
        get_yearmonth(@report.criteria.begin_date)|| @report.begin_time_unit,
        get_yearmonth(@report.criteria.end_date) || @report.end_time_unit
      ).size
    end
  end

  def aggregated_data_as_json
    return "" if @report.expense_history.empty?

    case @report.criteria.aggregation_mode
    when "daily"
      daily_report_as_data_points
    when "weekly"
      weekly_report_as_data_points
    when "monthly"
      monthly_report_as_data_points
    end
  end

  private

  def get_yearweek(date)
    date.strftime("%G%V").to_i if date
  end

  def get_yearmonth(date)
    date.strftime("%Y%m").to_i if date
  end

  def daily_report_as_data_points
    (@report.begin_time_unit .. @report.end_time_unit).map do |date|
      "{ x: new Date(#{date.year}, #{date.month - 1}, #{date.day})," +
      "  y: #{@report.expense_history[date] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def weekly_report_as_data_points
    year_weeks = calculate_year_weeks(@report.begin_time_unit, @report.end_time_unit)

    year_weeks.map do |yearweek|
      "{ label: 'week #{yearweek % 100}, #{yearweek / 100}', " +
      "  y: #{@report.expense_history[yearweek] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def calculate_year_weeks(begin_yearweek, end_yearweek)
    # format of time unit: <year in 4 digits><week number in 2 digits>
    # e.g. 201601 (which means the first week of year 2016)
    if begin_yearweek.nil? || end_yearweek.nil?
      return []
    end

    begin_year = begin_yearweek / 100
    end_year = end_yearweek / 100

    if begin_year == end_year
      year_weeks = (begin_yearweek .. end_yearweek)
    else
      weeks_of_begin_year =
        (begin_yearweek .. begin_year * 100 + number_of_weeks(begin_year)).to_a

      weeks_of_middle_years =
        (begin_year + 1 .. end_year - 1).map do |year|
          1.upto(number_of_weeks(year)).map { |week| year * 100 + week }
        end.flatten

      weeks_of_end_year = (end_year * 100 + 1 .. end_yearweek).to_a

      year_weeks = weeks_of_begin_year + weeks_of_middle_years + weeks_of_end_year
    end

    year_weeks
  end

  def number_of_weeks(year)
    Date.new(year, 12, 28).cweek # answer from stack overflow :)
  end

  def monthly_report_as_data_points
    year_months = calculate_year_months(@report.begin_time_unit, @report.end_time_unit)

    year_months.map do |yearmonth|
      "{ label: '#{ Date::ABBR_MONTHNAMES[yearmonth % 100] } #{ yearmonth / 100 }', " +
      "  y: #{@report.expense_history[yearmonth] / ExpenseEntry::CENTS_MULTIPLIER} }"
    end.join(",")
  end

  def calculate_year_months(begin_yearmonth, end_yearmonth)
    # format of time unit: <year in 4 digits><month in 2 digits>
    # e.g. 201601 (which means the first month of year 2016)
    if begin_yearmonth.nil? || end_yearmonth.nil?
      return []
    end

    begin_year = begin_yearmonth / 100
    end_year = end_yearmonth / 100

    if begin_year == end_year
      year_months = (begin_yearmonth .. end_yearmonth)
    else
      months_of_begin_year = (begin_yearmonth .. begin_year * 100 + 12).to_a

      months_of_middle_years =
        (begin_year + 1 .. end_year - 1).map do |year|
          (year * 100 + 1 .. year * 100 + 12).to_a
        end.flatten

      months_of_end_year = (end_year * 100 + 1 .. end_yearmonth).to_a

      year_months = months_of_begin_year + months_of_middle_years + months_of_end_year
    end

    year_months
  end
end