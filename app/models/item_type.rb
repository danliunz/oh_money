class ItemType < ActiveRecord::Base
  has_many :parent_relations, class_name: "ItemTypeRelation",
    foreign_key: "child_id", dependent: :destroy

  has_many :child_relations, class_name: "ItemTypeRelation",
    foreign_key: "parent_id", dependent: :destroy

  belongs_to :user, class_name: "Account::User"

  has_many :parents, through: :parent_relations
  has_many :children, through: :child_relations

  has_many :expense_entries, dependent: :destroy
end
