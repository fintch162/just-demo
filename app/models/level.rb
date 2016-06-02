class Level < List
  extend Filterable
  has_many :group_classes
end
