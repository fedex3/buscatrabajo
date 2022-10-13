class CompanyFavorite < ApplicationRecord
	belongs_to :company
	belongs_to :user

	validates :company, presence: true
	validates :user, presence: true

	validates_uniqueness_of :user_id, :scope => :company_id

	scope :order_by_date, -> { order(created_at: :desc) }
	scope :order_by_company, -> { order(company_id: :asc) }
	scope :order_by_user, -> { order(user_id: :asc) }
end
