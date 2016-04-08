class UpdateItemType
  def initialize(item_type, params)
    @item_type = item_type
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
    parents = parents_param.map do |parent_name|
      begin
        ItemType.find_or_create_by!(user: @item_type.user, name: parent_name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end

    parents.delete_if { |parent| parent == @item_type }

    @item_type.parents = remove_redundant_parents(parents)
  end

  def parents_param
    @params[:parents] || []
  end

  def remove_redundant_parents(parents)
    parents_with_no_redundancy = []

    parents.each do |parent|
      other_parents = parents.reject { |p| p == parent }

      unless is_ancestor_of(parent, other_parents)
        parents_with_no_redundancy << parent
      end
    end

    parents_with_no_redundancy
  end

  # return true if _item_type_ is ancestor of at least one of _other_item_types_
  def is_ancestor_of(item_type, other_item_types)
    other_item_types.each do |other_item_type|
      return true if other_item_type.ancestors.include?(item_type)
    end

    false
  end
end