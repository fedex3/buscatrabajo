class Job < ApplicationRecord
  include ShowPhotoName
  include FriendlyUrl

  belongs_to :company, optional: true
  has_many :job_applications

  has_and_belongs_to_many(:recommended_jobs,
  :join_table => "recommended_jobs",
  :foreign_key => "job_id",
  :association_foreign_key => "recommended_job_id",
  :class_name => "Job")

  has_attached_file :photo, {
    default_url: ActionController::Base.helpers.asset_path("missing.webp"),
  	#url: "/system/projects/logos/:hash.:extension",
	  hash_secret: "longSecretString",
    :styles => {:thumbnail => "200x133",  :small => "400x266#"},
    :convert_options => { :thumbnail => "-gravity center -extent 200x133"} 
}

  process_in_background :photo, processing_image_url: "/images/:style/processing.webp"

  validates_attachment_content_type :photo, content_type: /\Aimage/
  validates_attachment_file_name :photo, matches: [/png\Z/i, /jpe?g\Z/i, /webp\Z/i]
  after_save :tinify_photos , if: Proc.new { |job| job.saved_change_to_photo_updated_at? && Rails.env.production?}

  validates :name, length: { minimum: 1, maximum: 100}
  validates :detail, length: { minimum: 1, maximum: 20000}
  validates :name_id, presence: true, :uniqueness => {case_sensitive: false, :scope => :company_id}
  #validates :country, length: { presence: true, allow_blank: false}
  validates :views, numericality: { greater_than_or_equal_to: 0}
  validates :application_counter, numericality: { greater_than_or_equal_to: 0}
  validates :from_date, length: { presence: true, allow_blank: false}
  validates :end_date, length: { presence: true, allow_blank: false}

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  before_validation :create_name_id
  before_validation :remove_email
  #after_save :update_urls
  #after_create :update_order

  enum provider: %i[mibucle other avature greenhouse workday hiringroom publicis]

  scope :from_date, -> { where("date_trunc('day', jobs.from_date) <= ?", Date.today) }
  scope :end_date, -> { where("date_trunc('day', jobs.end_date) >= ?", Date.today) }
  scope :active, -> { where(active: true) }
  scope :listable, -> { active.from_date.end_date}
  scope :company_listable, -> {  joins(:company).where("companies.active = true and date_trunc('day', companies.from_date) <= ?", Date.today) }
  scope :company_listable_not_only_special_events, -> {  joins(:company).where("companies.active = true and date_trunc('day',companies.from_date) <= ?", Date.today) }
  scope :not_proactive_interview, -> { where.not(name: "Entrevistas proactivas" ) }
  scope :by_company_in_special_event, -> (special_event_code) { joins(:company).where("companies.id IN (?)", Company.joins(:company_special_events).where(company_special_events: { code: special_event_code }).ids) }
  scope :by_year, lambda { |year| where('extract(year from created_at) = ?', year) }

  scope :by_company, -> (company) { where company_id: company }
  scope :by_part_time, -> (part_time) { where part_time: part_time }
  scope :by_country, -> (country) { joins(:job_countries).where('job_countries.country_alpha2 = ?', country) }
  scope :by_not_this_country, -> (country) { joins(:job_countries).where.not('job_countries.country_alpha2 = ?', country) }
  scope :by_remote, -> (remote) { where remote: remote }

  scope :by_q, -> (q) { joins(:company).where("lower(jobs.name) LIKE ? OR lower(jobs.detail) LIKE ? OR  lower(companies.name) LIKE ?", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%", "%#{q}%")}

  scope :default_order, -> { order(name: :asc) }
  scope :order_by_date, -> { order(created_at: :desc) }
  scope :order_by_relevance, -> { order(order: :asc) }
  scope :order_by_default, -> { order(order: :asc) }
  scope :order_by_name, -> { order(name: :asc) }

  scope :with_photo, -> { where.not(photo_url: ["missing.webp", nil] ) }
  scope :without_photo, -> { where(photo_url: ["missing.webp", nil]) }

	def id_name
		id.to_s + ' - ' + company.name + ' - ' + name
	end

	def validate_email?
		email.present?
	end

  def update_urls
    if photo(:small).to_s != photo_url
      self.update_column(:photo_url,photo(:small).to_s)
    end
  end

	def create_recommended_jobs
		return if !mibucle? && !other?
		calculate_recommended_jobs
	end

	def calculate_recommended_jobs
		recommendations = Set.new

    if company&.jobs.present?
      company.jobs.listable.order_by_date.limit(ENV['JOB_RECOMMENDATIONS'].to_i + 1).each do |recommended_job|
        recommendations << recommended_job
      end
    end

		#Si no llegue al numero, completo con las mas nuevas
		if recommendations.size <= ENV['JOB_RECOMMENDATIONS'].to_i  && company.active
			Job.company_listable.listable.order_by_date.limit(ENV['JOB_RECOMMENDATIONS'].to_i + 1).each do |recommended_job|
				unless recommendations.include?(recommended_job)
					recommendations << recommended_job
				end
			end
		end

		self.recommended_jobs.destroy_all
		self.recommended_jobs << (recommendations - [self]).take(ENV['JOB_RECOMMENDATIONS'].to_i)
	end

	def create_name_id
		self.name_id = friendly_url(name)
	end

  def increment_counter
    self.update_column(:application_counter, application_counter + 1)
  end

  def update_order
  	return if !mibucle? && !other?
  	Job.update_order
  end

  def listable
    active && Time.current.between?(from_date, end_date)
  end

  def remove_email
		emails = detail.scan(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)
		emails.each do |email|
			self.detail = self.detail.gsub(email,'')
		end
  end

  def self.recommended_jobs(locale)
    jobs = Job.company_listable_not_only_special_events.listable.joins(:company).preload(:company).select("jobs.active, jobs.updated_at, jobs.part_time, jobs.company_id, jobs.name, jobs.name_id, jobs.id, jobs.photo_file_name, jobs.photo_updated_at, jobs.city, jobs.country, jobs.remote")
    jobs = jobs.with_photo.by_country(locale).last(6)
  end

  private
    def tinify_photos #Compresses all images uploaded with paperclip. Must add "after_save :tinify_photos , if: Proc.new { |instance| instance.saved_change_to_??attachment_name??_updated_at?}"
      paths = [self.photo.path(:original), self.photo.path(:thumbnail), self.photo.path(:small)]
      TinifyToS3.perform_async(paths)
    end
end
