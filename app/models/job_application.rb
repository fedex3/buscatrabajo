class JobApplication < ApplicationRecord
  include AASM
=begin
  aasm do
    state :pending, initial: true
    state :accepted, :rejected, :positive_rejected, :on_standby

    event :accept do
      transitions from: [:pending, :rejected, :positive_rejected, :on_standby], to: :accepted
    end

    event :reject do
      transitions from: [:pending, :accepted, :positive_rejected, :on_standby], to: :rejected
    end

    event :positive_reject do
      transitions from: [:pending, :accepted, :rejected, :on_standby], to: :positive_rejected
    end

    event :put_on_standby do
      transitions from: [:pending, :accepted, :rejected, :positive_rejected], to: :on_standby
    end

    event :to_pending do
      transitions from: [:accepted, :rejected, :positive_rejected, :on_standby], to: :pending
    end
  end
=end
  belongs_to :job
  belongs_to :user
  belongs_to :user_cv

  has_many :user_tests, through: :users

  validates :comment, length: { maximum: 500}
  validates :job, :presence => true
  validates :user, :presence => true, if: :full
  validates :user_cv, :presence => true, if: :full
  validates_uniqueness_of :user_id, :scope => :job_id, if: :full

  validates :email, presence: true, length: { maximum: 100 }
  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
  validates_uniqueness_of :email, :scope => :job_id, :case_sensitive => false

  has_attached_file :cv,{
    hash_secret: "longSecretString"
  }

  after_create :increment_counter

  scope :job, ->(job_id) { where(job_id: job_id) }
  scope :full, -> { where(full: true) }
  scope :order_by_date_desc, -> { order(created_at: :desc) }
  scope :by_rejected, -> (rejected) { joins(:user).where(users: {rejected: rejected}) }
  scope :by_language, -> (language) { joins(:user).where(users: {language: language}) }
  scope :by_cv_status, -> (cv_status) { joins(:user).where(users: {cv_status: cv_status}) }
  scope :by_study_level, -> (study_level) { joins(user: [:study_level]).where(study_levels: {id: study_level} ) }
  scope :by_company, -> (company) { joins(:job).where(jobs: {company_id: company} ) }
  scope :by_job_area, -> (job_area) { joins(user:  [:users_job_areas]).where(users_job_areas: {job_area_id: job_area} ) }
  scope :by_q, -> (q) { joins(job: [:company]).where("lower(job_applications.email) LIKE ? OR lower(companies.name) LIKE ? OR lower(jobs.name) LIKE ?", "%#{q}%", "%#{q}%", "%#{q}%") }
  scope :by_year, lambda { |year| where('extract(year from created_at) = ?', year) }

  def increment_counter
    self.job.increment_counter
  end

  def create_application(user_id, user_mail, job_name_id)
    @job_id = Job.find_by(name_id: job_name_id).id
    if JobApplication.find_by(user_id: user_id, job_id: @job_id).nil?
      self.job_id = @job_id
      self.user_id = user_id
      self.email = user_mail
      self.rejected = false
      self.aasm_state = "pending"
      self.full = false
      puts self.inspect

      unless self.save
        self.errors.messages.each do |msg|
          self.errors.append(msg)
        end
        puts "Algo salió mal"
      end
    end
  end
end