class ItemType < ActiveRecord::Base
  has_many :parent_relations, class_name: "ItemTypeRelation",
    foreign_key: "child_id", dependent: :destroy
  has_many :parents, through: :parent_relations

  has_many :child_relations, class_name: "ItemTypeRelation",
    foreign_key: "parent_id", dependent: :destroy
  has_many :children, through: :child_relations

  belongs_to :user, class_name: "Account::User"
  has_many :expense_entries, inverse_of: :item_type, dependent: :destroy

  # TODO: remove dependence between the 2 validations below or make the code more readable
  validates_presence_of :name, :user
  validates_uniqueness_of :name, scope: :user_id, if: proc { errors.empty? }

  scope :names_matching_prefix, ->(name_prefix, owner) {
    where(user: owner)
    .where("name LIKE ?", "#{name_prefix}%")
    .order(name: :asc)
    .pluck(:name)
  }

  def as_json
    {
      name: name,
      description: description
    }
  end
end
