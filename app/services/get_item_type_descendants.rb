class GetItemTypeDescendants
  attr_reader :root_item_type

  def initialize(root_item_type)
    @root_item_type = root_item_type
    @descendants = []
  end

  def call
    add_descendants_of(@root_item_type)

    @descendants
  end

  private

  def add_descendants_of(item_type)
    @descendants.concat(item_type.children)

    # some item type appears once than once in hierarchy tree
    if @descendants.uniq.size != @descendants.size
      raise ItemTypeRelation::CircularDependencyError, @root_item_type
    end

    item_type.children.each do |child|
      add_descendants_of(child)
    end
  end
end