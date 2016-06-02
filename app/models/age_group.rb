class AgeGroup < List
  extend Filterable
  has_many :group_classes
  has_many :registration_packages
  has_many :coordinator_classes
end