class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable


  has_attached_file :photo, {
    default_url: "",
    #url: '/system/projects/logos/:hash.:extension',
    hash_secret: 'longSecretString',
    styles: { thumbnail: '100x100#', medium: '500x500#'}
  }

  validates_attachment_content_type :photo, content_type: /\Aimage/
  validates_attachment_file_name :photo, matches: [/gif\Z/, /png\Z/, /jpe?g\Z/, /JPE?G\Z/, /webp\Z/, /WEBP\Z/]
  after_save :tinify_photos , if: Proc.new { |user| user.saved_change_to_photo_updated_at? && Rails.env.production?}

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, :omniauth_providers => [:facebook, :linkedin]

  has_many :event_users
  has_many :company_special_events, through: :event_users

  has_many :coaching_booking
  has_many :mentor_booking
  has_many :advice_favorites
  has_many :advice, through: :advice_favorites
  has_many :answer

  has_many :company_favorites
  has_many :company, through: :company_favorites
  has_one :working_company, class_name: 'Company'

  has_many :job_favorites
  has_many :job, through: :job_favorites

  has_many :job_applications
  has_many :apply_job, :through => :job_applications, :source => :job
  has_many :user_cvs
  has_many :user_tests, dependent: :destroy

  has_one :newsletter
  accepts_nested_attributes_for :newsletter


  has_and_belongs_to_many :advices
  has_and_belongs_to_many :companies
  has_and_belongs_to_many :jobs
  has_and_belongs_to_many :job_areas,  :join_table => 'users_job_areas'
  belongs_to :study_level

  attr_accessor :login_social
  attr_accessor :skip_terms_validation

  validates :analytics_client_id, length: { maximum: 100 }
  validate :terms_accepted, :terms_is_valid, unless: :skip_terms_validation
  validates :name, length: { minimum: 1}, unless: :login_social
  #validates :country, length: { presence: true, allow_blank: false}, unless: :login_social

  # TODO: Eliminar los campos cv_status y rejected y actualizar los scopes que usen esos campos
  # ya que ahora se usa aasm_state en JobApplication.
  enum cv_status: %i[pending cv_rejected cv_accepted positive_rejected on_standby]
  enum role: %i[basic recruiter community_manager admin superadmin company_role content_editor content_editor_plus]

  before_save :update_terms_created_at
  before_validation :update_omniauth, if: :omniauth

  after_initialize :set_defaults, if: :new_record?
  after_create :track_analytics
  after_create :upsert_newsletter

  scope :with_cv, -> { joins(:user_cvs).where.not(user_cvs: {id: nil}).distinct}
  scope :by_rejected, -> (rejected) { where(rejected: rejected) }
  scope :by_language, -> (language) { where(language: language) }
  scope :by_cv_status, -> (cv_status) { where(cv_status: cv_status) }
  scope :by_study_level, -> (study_level) { joins(:study_level).where(study_levels: {id: study_level} ) }
  scope :by_job_area, -> (job_area) { joins(:users_job_areas).where(users_job_areas: {job_area_id: job_area} ) }
  scope :by_q, -> (q) { where("lower(users.email) LIKE ? OR lower(users.name) LIKE ?", "%#{q}%", "%#{q}%") }
  scope :order_by_date, -> { order(created_at: :desc) }


  def age
    DateTime.now().year - DateTime.new(born_year,1,1).year if born_year.present?
  end

  def track_analytics
    if Rails.env.production?
      cid = nil
      unless analytics_client_id.blank?
        cid = analytics_client_id
      end
      tracker = Staccato.tracker(ENV['ANALYTICS_TRACKING_ID'], cid)
      tracker.event(category: 'Sign up', action: 'Sign up', label: id.to_s, value: 1)
    end
  end

  def update_omniauth
    if self.current_password != self.password && !reset_password_token.nil?
      self.omniauth = false
    end
  end

  def terms_is_valid
    unless self.terms_accepted?
       self.errors.add(:terms_accepted, I18n.t('users.validations.terms_accepted'))
    end
	end

	def update_terms_created_at
    if self.terms_accepted_changed?(from: false, to: true)
      self.terms_accepted_at = Time.now
    end
	end

  def set_defaults
    self.role ||= :basic
  end

  def upsert_newsletter
    Newsletter.upsert_newsletter(self)
  end

  def self.from_omniauth(auth)
    if where(email: auth.info.email).exists?
        return_user = where(email: auth.info.email).first
        return_user.provider = auth.provider
        return_user.uid = auth.uid
        return_user.save!(:validate => false)
    else
      return_user = create do |user|
        user.terms_accepted = true
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.name = auth.info.name
        if auth.provider == 'linkedin' && !auth.info.location.nil?
          user.country = auth.info.location.last(2)
        end
        user.password = Devise.friendly_token[0,20]
        user.omniauth = true
        user.save!
      end
    end
    return return_user
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
        #Rails.logger.debug("Loggeando cosas: model: if :" + user.email)
      end
    end
  end

  def user_in_spain?(session)
    @is_in_spain = false
    if self.country == 'ES'
      @is_in_spain = true
    elsif I18n.locale.to_s == 'es'
      @is_in_spain = true
    elsif session[:country] == 'es'
      @is_in_spain = true
    end
    return @is_in_spain
  end

  def user_in_chile?(session)
    @is_in_chile = false
    if self.country == 'CL'
      @is_in_chile = true
    elsif I18n.locale.to_s == 'cl'
      @is_in_chile = true
    elsif session[:country] == 'cl'
      @is_in_chile = true
    end
    return @is_in_chile
  end

  private
    def tinify_photos #Compresses all images uploaded with paperclip. Must add "after_save :tinify_photos , if: Proc.new { |instance| instance.saved_change_to_´attachment_name´_updated_at?}"
      paths = [self.photo.path(:original), self.photo.path(:thumbnail), self.photo.path(:medium)]
      TinifyToS3.perform_async(paths)
    end
end
