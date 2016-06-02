class Feature < ActiveRecord::Base
	has_many :instructor_features, dependent: :destroy
	has_many :instructors,through: :instructor_features
	scope :reddot_card_id, -> {find_by_feature_name('Reddot Visa/Master').id}
	scope :eNets_id, -> {find_by_feature_name('Reddot eNets').id}
end
