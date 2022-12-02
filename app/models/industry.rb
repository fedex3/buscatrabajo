class Industry < ApplicationRecord
	acts_as_paranoid
	include FriendlyUrl

	has_and_belongs_to_many :companies
	has_many :jobs

	validates :name, length: { minimum: 1, maximum: 100}
	validates :name_id, uniqueness: {case_sensitive: false}

	before_validation :create_name_id
	scope :order_by_name, -> { order(name: :asc) }
	scope :order_by_menu, -> { order(order: :asc) }

	def create_name_id
		self.name_id = friendly_url(name) if name.present?
	end
end
