class UpdateItemTypeService
  def initialize(item_type, user, params)
    @item_type = item_type
    @user = user
    @params = params
  end

  def call
    begin
      ItemType.transaction { update }
    rescue ActiveRecord::RecordInvalid
      return false
    end

    true
  end

  private

  def update
    @item_type.description = @params[:description]

    update_parents

    @item_type.save!
  end

  def update_parents
    @item_type.parents = @params[:parents].map do |parent_name|
      begin
        ItemType.find_or_create_by!(user: @user, name: parent_name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
  end
end