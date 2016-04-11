class UpdateItemType
  class CircularDependency < StandardError
  end

  attr_reader :error

  def initialize(item_type, params)
    @item_type = item_type
    @params = params
  end

  def call
    ItemType.transaction { update }
  rescue => exception
    @error = exception.to_s
    false
  else
    true
  end

  private

  def update
    update_name
    update_description
    update_parents

    @item_type.save!
  end

  def update_name
    @item_type.name = @params[:name]
  end

  def update_description
    @item_type.description = @params[:description]
  end

  def update_parents
    parents = parents_param.map do |parent_name|
      begin
        ItemType.find_or_create_by!(user: @item_type.user, name: parent_name)
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end

    remove_itself_from_parents(parents)

    check_circular_dependency(parents)

    remove_redundant_parents(parents)

    @item_type.parents = parents
  end

  def parents_param
    @params[:parents] || []
  end

  def remove_itself_from_parents(parents)
    parents.delete_if { |parent| parent == @item_type }
  end

  def check_circular_dependency(parents)
    parents.each do |parent|
      if parent.ancestors.include?(@item_type)
        raise CircularDependency, "category '#{parent.name}' belongs to '#{@item_type.name}'"
      end
    end
  end

  # suppose there are "A" and "B" in _parents_
  # and "A" is ancestor of "B", we can safely remove "A"
  # from _parents_ to keep only the most direct parent for @item_type
  def remove_redundant_parents(parents)
    parents_with_no_redundancy = []

    parents.each do |parent|
      other_parents = parents.reject { |p| p == parent }

      unless is_ancestor_of(parent, other_parents)
        parents_with_no_redundancy << parent
      end
    end

    parents.replace(parents_with_no_redundancy)
  end

  # return true if _item_type_ is ancestor of at least one of _other_item_types_
  def is_ancestor_of(item_type, other_item_types)
    other_item_types.each do |other_item_type|
      return true if other_item_type.ancestors.include?(item_type)
    end

    false
  end
end