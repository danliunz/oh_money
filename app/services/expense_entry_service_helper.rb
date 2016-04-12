# help create or update expense entry by HTTP request
module ExpenseEntryServiceHelper
  def cost_in_cents
    (Float(@params[:cost]) * ExpenseEntry::CENTS_MULTIPLIER).round
  rescue
    nil
  end

  def purchase_date
    @params[:purchase_date] ? Date.parse(@params[:purchase_date]) : Date.today
  rescue
    nil
  end

  def set_tags
    tag_names = @params[:tags] ?
      @params[:tags].collect { |tag| tag["name"] }.compact.uniq : []

    @expense_entry.tags = tag_names.map { |name| find_or_create_tag(name) }
  end

  def find_or_create_tag(tag_name)
    Tag.find_or_create_by(name: tag_name, user: @user)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end