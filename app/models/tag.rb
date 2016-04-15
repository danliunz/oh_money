class Tag < ActiveRecord::Base
  belongs_to :user, class_name: "Account::User"
  has_and_belongs_to_many :expense_entries, join_table: "expense_entry_tags"

  validates_presence_of :name, :user

  scope :names_matching_prefix, ->(name_prefix, owner) {
    where(user: owner)
    .where("name LIKE ?", "#{name_prefix}%")
    .order(name: :asc)
    .pluck(:name)
  }

  def as_json(options = nil)
    { name: name, description: description }
  end
end
