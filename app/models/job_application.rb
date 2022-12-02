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

  has_many :user_tests, through: :users

  validates :comment, length: { maximum: 500}
  validates :job, :presence => true
  validates_uniqueness_of :user_id, :scope => :job_id


  has_attached_file :cv,{
    hash_secret: "longSecretString"
  }

  after_create :increment_counter

  scope :job, ->(job_id) { where(job_id: job_id) }
  scope :order_by_date_desc, -> { order(created_at: :desc) }
  scope :by_rejected, -> (rejected) { joins(:user).where(users: {rejected: rejected}) }
  scope :by_language, -> (language) { joins(:user).where(users: {language: language}) }
  scope :by_company, -> (company) { joins(:job).where(jobs: {company_id: company} ) }
  scope :by_q, -> (q) { joins(job: [:company]).where("lower(companies.name) LIKE ? OR lower(jobs.name) LIKE ?", "%#{q}%", "%#{q}%", "%#{q}%") }
  scope :by_year, lambda { |year| where('extract(year from created_at) = ?', year) }

  def increment_counter
    self.job.increment_counter
  end

  def create_application(user_id, user_mail, job_name_id)
    @job_id = Job.find_by(name_id: job_name_id).id
    if JobApplication.find_by(user_id: user_id, job_id: @job_id).nil?
      self.job_id = @job_id
      self.user_id = user_id

      unless self.save
        self.errors.messages.each do |msg|
          self.errors.append(msg)
        end
        puts "Algo salió mal"
      end
    end
  end
end