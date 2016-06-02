class Venue < ActiveRecord::Base
  extend Filterable

  has_many :group_classes
  has_many :award_test, dependent: :destroy
  # has_many :jobs
  has_many :job_venues
  has_many :jobs, :through => :job_venues

  has_many :coordinator_classes
  
  validates :name, presence: true

	def name_with_initial
    @name = "#{name}"
    @name.to_s.sub("Swimming Complex", 'SC')
  end
end
