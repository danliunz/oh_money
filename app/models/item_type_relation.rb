# ItemType can form hierarchy like a family tree
class ItemTypeRelation < ActiveRecord::Base
  belongs_to :child, class_name: "ItemType"
  belongs_to :parent, class_name: "ItemType"
end