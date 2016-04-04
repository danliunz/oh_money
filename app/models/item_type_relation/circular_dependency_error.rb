class ItemTypeRelation
  class CircularDependencyError < StandardError
    attr_accessor :root_item_type

    def initialize(root_item_type)
      @root_item_type = root_item_type
    end

    def to_s
      "Circular child/parent relation found for item type #{root_item_type.name}"
    end
  end
end