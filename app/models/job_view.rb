class JobView < ApplicationRecord
  belongs_to :job
  belongs_to :user

  validates :job, presence: true

  scope :order_by_date, -> { order(created_at: :desc) }
  scope :order_by_job, -> { order(job_id: :asc) }
  scope :order_by_user, -> { order(email: :asc) }
  scope :by_company, ->(company) { joins(:job).where(jobs: { company_id: company }) }
end
