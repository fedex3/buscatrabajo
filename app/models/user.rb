class User < ApplicationRecord

  devise :database_authenticatable, :registerable,
        :recoverable, :rememberable, :validatable

  has_many :job_applications
  has_many :apply_job, :through => :job_applications, :source => :job

  has_and_belongs_to_many :companies
  has_and_belongs_to_many :jobs

  attr_accessor :skip_terms_validation

  validates :name, length: { minimum: 1, message: "Nombre muy corto"}
  #validates :country, length: { presence: true, allow_blank: false}, unless: :login_social

  enum cv_status: %i[pending cv_rejected cv_accepted positive_rejected on_standby]
  enum role: %i[basic recruiter community_manager admin superadmin company_role content_editor content_editor_plus]

  after_initialize :set_defaults, if: :new_record?

  scope :by_q, -> (q) { where("lower(users.email) LIKE ? OR lower(users.name) LIKE ?", "%#{q}%", "%#{q}%") }
  scope :order_by_date, -> { order(created_at: :desc) }


  def age
    DateTime.now().year - DateTime.new(born_year,1,1).year if born_year.present?
  end

  def set_defaults
    self.role ||= :basic
  end

  private
end
