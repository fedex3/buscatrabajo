class CompanyView < ApplicationRecord
	belongs_to :company
	belongs_to :user

	validates :company, presence: true

	scope :order_by_date, -> { order(created_at: :desc) }
	scope :order_by_company, -> { order(company_id: :asc) }
	scope :order_by_user, -> { order(email: :asc) }

end
