class CreateExpenseEntry
  def initialize(params, user)
    @params = params
    @user = user

    @expense_entry = ExpenseEntry.new
  end

  def call
    @expense_entry.user = @user
    @expense_entry.item_type = find_or_create_item_type
    @expense_entry.cost = cost_in_cents
    @expense_entry.purchase_date = purchase_date

    add_tags_to_expense_entry

    @expense_entry.save
  end

  def value
    @expense_entry
  end

  private

  def find_or_create_item_type
    ItemType.find_or_create_by(name: @params[:item_type]["name"], user: @user)
  rescue ActiveRecord::RecordNotUnique
    retry
  end

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

  def add_tags_to_expense_entry
    tag_names = @params[:tags] ?
      @params[:tags].collect { |tag| tag["name"] }.compact : []

    tag_names.each do |tag_name|
      @expense_entry.tags << find_or_create_tag(tag_name)
    end
  end

  def find_or_create_tag(tag_name)
    Tag.find_or_create_by(name: tag_name, user: @user)
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end